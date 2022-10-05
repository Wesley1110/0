import QuantLib as ql

settings = ql.Settings.instance()
evDate = ql.Date(8, 6, 2021)  # 2021-06-08
settings.setEvaluationDate(evDate)

Cal = ql.NullCalendar()
DC365 = ql.Actual365Fixed()
settlementDays = 2
refDate = Cal.advance(evDate, 2, ql.Days, ql.Following, False)
maturity = ql.Date(10, 6, 2022)  # 2022-06-10

europeanExer = ql.EuropeanExercise(maturity)
vanillaPayoff = ql.PlainVanillaPayoff(ql.Option.Call, 100.0)  # K=100

S0 = 100
Q_S = ql.SimpleQuote(S0)
hQ_S = ql.QuoteHandle(Q_S)

r = 0.05
rTS = ql.FlatForward(settlementDays, Cal, r, DC365, ql.Compounded, ql.Annual)
h_rTS = ql.YieldTermStructureHandle(rTS)

q = 0.03
qTS = ql.FlatForward(settlementDays, Cal, q, DC365, ql.Compounded, ql.Annual)
h_qTS = ql.YieldTermStructureHandle(qTS)

vol = 0.3
volTS = ql.BlackConstantVol(evDate, Cal, vol, DC365)
h_volTS = ql.BlackVolTermStructureHandle(volTS)

GBSProcess = ql.GeneralizedBlackScholesProcess(hQ_S, h_qTS, h_rTS, h_volTS)
AEE = ql.AnalyticEuropeanEngine(GBSProcess)

anEuroOption = ql.EuropeanOption(vanillaPayoff, europeanExer)
anEuroOption.setPricingEngine(AEE)

Value = anEuroOption.NPV()
print("MTM", Value)  # 按照原Vol設定30%計算C0買權價格

ImpVol = anEuroOption.impliedVolatility(15.0, GBSProcess)  # assume option price = 15  價格是波動度的遞增函數
print(ImpVol)

ImpVol = anEuroOption.impliedVolatility(9.0, GBSProcess)  # assume option price = 9
print(ImpVol)


import QuantLib as ql

settings = ql.Settings.instance()
evDate = ql.Date(8, 6, 2021)    #  dd-mm-yy 2021.06.08
settings.setEvaluationDate(evDate)

Cal = ql.NullCalendar()
DC365 = ql.Actual365Fixed()  # 計息方式Actual365
settlementDays = 2           # option通常2天交割
refDate = Cal.advance(evDate, 2, ql.Days, ql.Following, False)  # 推遲2天
maturity = ql.Date(10, 6, 2022)                                 # 到期日 2022.06.10

europeanExer = ql.EuropeanExercise(maturity)
vanillaPayoff = ql.PlainVanillaPayoff(ql.Option.Call, 100.0)  # ql.Option.Call ; ql.Option.Put ; 履約價 $100

S0 = 100  # 期初股價
Q_S = ql.SimpleQuote(S0)
hQ_S = ql.QuoteHandle(Q_S)

r = 0.08  # 水平的利率期間結構
rTS = ql.FlatForward(settlementDays, Cal, r, DC365, ql.Compounded, ql.Annual)
h_rTS = ql.YieldTermStructureHandle(rTS)

q = 0.05  # 股利，if期貨選擇權(台指選)設為0
qTS = ql.FlatForward(settlementDays, Cal, q, DC365, ql.Compounded, ql.Annual)
h_qTS = ql.YieldTermStructureHandle(qTS)

vol = 0.3  # 波動度
volTS = ql.BlackConstantVol(evDate, Cal, vol, DC365)
h_volTS = ql.BlackVolTermStructureHandle(volTS)

GBSProcess = ql.GeneralizedBlackScholesProcess(hQ_S, h_qTS, h_rTS, h_volTS)
AEE = ql.AnalyticEuropeanEngine(GBSProcess)  # 解析解

anEuroOption = ql.EuropeanOption(vanillaPayoff, europeanExer)  # option物件
anEuroOption.setPricingEngine(AEE)  # 設定評價引擎

Value = anEuroOption.NPV()
print("MTM", Value)  # 選擇權價格

Delta = anEuroOption.delta()
Gamma = anEuroOption.gamma()
Vega = anEuroOption.vega()
Theta = anEuroOption.theta()
Rho = anEuroOption.rho()
Rho1 = anEuroOption.dividendRho()

print("Delta: ", Delta)
print("Gamma: ", Gamma)
print("Vega: ", Vega)

# 改變S0資產價格
S0 = 101.0
Q_S = ql.SimpleQuote(S0)
hQ_S = ql.QuoteHandle(Q_S)
GBSProcess = ql.GeneralizedBlackScholesProcess(hQ_S, h_qTS, h_rTS, h_volTS)
AEE = ql.AnalyticEuropeanEngine(GBSProcess)
anEuroOption.setPricingEngine(AEE)
Value = anEuroOption.NPV()
print("MTM", Value)

# 更換二項式引擎
S0 = 100.0
Q_S = ql.SimpleQuote(S0)
hQ_S = ql.QuoteHandle(Q_S)
GBSProcess = ql.GeneralizedBlackScholesProcess(hQ_S, h_qTS, h_rTS, h_volTS)
BCRR = ql.BinomialCRRVanillaEngine(GBSProcess, 50)  # 二項式；50期
anEuroOption.setPricingEngine(BCRR)
Value = anEuroOption.NPV()
print("MTM", Value)

# 更換蒙地卡羅模擬引擎
S0 = 100.0
Q_S = ql.SimpleQuote(S0)
hQ_S = ql.QuoteHandle(Q_S)
GBSProcess = ql.GeneralizedBlackScholesProcess(hQ_S, h_qTS, h_rTS, h_volTS)
MCE = ql.MCEuropeanEngine(GBSProcess, "pseudorandom", timeSteps=1, requiredTolerance=0.02, seed=42)  # 蒙地卡羅模擬；假亂數(另有準亂數)；1步到底；誤差容錯率2%；亂數種子set seed=42  
anEuroOption.setPricingEngine(MCE)
Error = anEuroOption.errorEstimate()
Value = anEuroOption.NPV()
print(Value)
print(Error)

# 繪製BS model 價格線；X軸=不同S0價格；Y軸=期初選擇權C0價格
VecC0 = list()
XLabel = list()
for i in range(0, 20):
    S0 = 100.0 + (i-10) * 5  # S0 = $50 ~ $150
    XLabel.append(S0)
    Q_S = ql.SimpleQuote(S0)
    hQ_S = ql.QuoteHandle(Q_S)
    GBSProcess = ql.GeneralizedBlackScholesProcess(hQ_S, h_qTS, h_rTS, h_volTS)
    AEE = ql.AnalyticEuropeanEngine(GBSProcess)
    anEuroOption.setPricingEngine(AEE)
    Value = anEuroOption.NPV()
    VecC0.append(Value)
print(VecC0)


import matplotlib.pyplot as plt

plt.figure(figsize=(9, 5))
plt.plot(XLabel, VecC0)
plt.grid(True)
plt.xlabel('Stock Price')
plt.ylabel('Call Value')
plt.title('BS Model Values')
plt.show()


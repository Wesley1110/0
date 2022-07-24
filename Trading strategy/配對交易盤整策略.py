# 建構一個配對交易策略: 買進GLD 放空GDX，或是反過來，兩者價差組合具有mean reversion的特性，價差負向擴大時long，正向擴大時short
# 以避險比率進行配對交易(迴歸的beta)
# 訓練期設2/3的資料，測試期1/3

import math
import numpy as np
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt

gld = pd.read_csv('GLD.csv', index_col = 0, parse_dates = True)  # 黃金現貨價格
gdx = pd.read_csv('GDX.csv', index_col = 0, parse_dates = True)  # 一籃子金礦相關股票指數

print(gld.info())  # 385筆data
print(gld[0:10])

print(gdx.info())
print(gdx[0:10])

# 訓練期252日
OBS = 252
y = np.array(gld['Adj Close'][0:OBS])  # 被解釋變數
x = np.array(gdx['Adj Close'][0:OBS])  # 解釋變數
X = sm.add_constant(x)                 # 迴歸常數項

# plot
plt.figure(figsize=(9, 5))
plt.subplot(211)  # subplot(nrows, ncols, plot_number)
plt.plot(y, lw=1.5, label='gld')
plt.plot(y, 'ro')  # 可改成'r'
plt.grid(True)
plt.legend(loc=0)
plt.ylabel('$Price$')
plt.title('Time Serice of Prices')

plt.subplot(212)
plt.plot(x, 'g', lw=1.5, label='gdx')
plt.plot(x, 'bx')  # 可改成'b'
plt.grid(True)
plt.legend(loc=0)
plt.ylabel('$Price$')
plt.xlabel('$Date$')
plt.show()

# 迴歸分析 hedge ratio
model = sm.OLS(y, X)
results = model.fit()
hedgeRatio = results.params[1]  # 即 beta

# results.params 可print看看
hedgeRatio

# 策略價差
gld_adjClose = gld['Adj Close']
gdx_adjClose = gdx['Adj Close']
spread = gld_adjClose - hedgeRatio * gdx_adjClose  # 這裡的價差就是迴歸的error(y和y_hat的差距)
spreadTrain = spread[0:OBS]

# 價差圖示
plt.figure(figsize=(9, 5))
plt.plot(spread, lw=1.5, label='spread')
plt.plot(spreadTrain, 'ro', label='Train')
plt.grid(True)
plt.legend(loc=0)
plt.xlabel('$Date$')
plt.ylabel('$Spread Price$')
plt.title('Pair Trade Performance')
plt.show()

# 價差統計量(training)
spreadMean = spreadTrain.mean()
spreadStd = spreadTrain.std()
print(spreadMean)
print(spreadStd)

# 價差Z值 z-score(把spread標準化)
zscore = (spread - spreadMean) / spreadStd
print(zscore[:10])
print(zscore[-10:])

# 兩個標準差，買賣區間
longs = zscore <= -2  # 小於-2時long價差 
shorts = zscore >= 2  # 大於2時short價差
exits = np.abs(zscore) <= 1  # long後，-1回補；short後，1回補

print(longs)
print(shorts)
print(exits)

positions = np.array(len(spread)*[None, None])
positions.shape = (len(spread), 2)  # row, column
print(positions)

# 把position的None, None填入數字
for i, b in enumerate(shorts):
    if b:
        positions[i] = [-1, 1]

for i, b in enumerate(longs):
    if b:
        positions[i] = [1, -1]

for i, b in enumerate(exits):
    if b:
        positions[i] = [0, 0]

for i, b in enumerate(positions):
    if b[0] == None :
        positions[i] = positions[i-1]

print(positions[:10])
print(positions[-10:])

# 計算 GLD、GDX 日報酬率
OBS = 385                                # all data
cl1 = np.array(gld['Adj Close'][0:OBS])  # 收盤價385筆
cl2 = np.array(gdx['Adj Close'][0:OBS])

ret_cl1 = np.diff(cl1) / cl1[:-1]        # 報酬率384筆
ret_cl2 = np.diff(cl2) / cl2[:-1]

dailyret = np.concatenate((ret_cl1, ret_cl2), axis=0)
dailyret

# 把 dailyret 做 reshape
dailyret = np.reshape(dailyret, (OBS-1, 2), order = 'F')
dailyret

# 部位與績效
PL = positions[:-1] * dailyret  # 每日兩個部位的return
pnl = np.sum(PL, axis = 1)      # 每日兩部位的return加總(策略日報酬)

plt.figure(figsize=(9, 5))
plt.plot(pnl, lw=1.5, label='pnl')
plt.grid(True)
plt.legend(loc=0)
plt.xlabel('$Date$')
plt.ylabel('$Profit_Loss$')
plt.title('Strategy PL')
plt.show()

total = np.sum(pnl)
print(total)  # 策略總報酬率

# sharp ratio
sharpTrainset = math.sqrt(252)*np.mean(pnl[0:251])/np.std(pnl[0:251])  # 乘上math.sqrt(252)是分子和分母約分後的結果(sharp ratio要用年化報酬/年化標準差)
sharpTestset = math.sqrt(252)*np.mean(pnl[252:OBS-1])/np.std(pnl[252:OBS-1])
print('sharpTrainset: ', sharpTrainset)
print('sharpTestset: ', sharpTestset)



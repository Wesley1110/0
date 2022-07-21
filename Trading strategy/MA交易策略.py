#################
# MA趨勢交易策略 #
#################
import numpy as np
import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt

# data = yf.Ticker('^GSPC')
# sp500 = data.history(period='D', start='2000-1-3', end='2014-4-14')
sp500 = pd.read_csv('GSPC_2000_2014.csv', index_col = 0, parse_dates = True)  # SP500指數
print(sp500.info())

print(sp500[0:10])
sp500.head(10)  # better
sp500.tail(10)

sp500['42d'] = np.round(sp500['Close'].rolling(window=42, center=False).mean(), 2)  # 新增 42MA column、小數點2位
sp500['252d'] = np.round(sp500['Close'].rolling(window=252, center=False).mean(), 2)  # 新增 252MA column

# plot price
plt.figure(figsize=(9, 5))
plt.plot(sp500['Close'])
plt.grid(True)
plt.show()

# plot price and MA
plt.figure(figsize=(9, 5))
plt.plot(sp500[['Close', '42d', '252d']])
plt.grid(True)
plt.show()

# plot with legend(圖例)
sp500[['Close', '42d', '252d']].plot(grid=True, figsize=(9, 5))
plt.show()

# Method 2. plot by seaborn
import seaborn
seaborn.set()
sp500[['Close', '42d', '252d']].plot()  # 調整圖片大小 plot(grid=True, figsize=(9, 5))，其中 figsize=(9, 5) 寬,高

# 新增 42MA-252MA 價差column
sp500['42-252'] = sp500['42d'] - sp500['252d']
print(sp500['42-252'].tail())

# 價差訊號 大於50點為1 小於-50點為-1 其餘為0
SD = 50
sp500['Regime'] = np.where(sp500['42-252'] > SD, 1, 0)
sp500['Regime'] = np.where(sp500['42-252'] < -SD, -1, sp500['Regime'])
sp500['Regime'].value_counts()

# 訊號分佈圖
plt.figure(figsize=(9, 5))
plt.plot(sp500[['Regime']])
plt.ylim([-1.1, 1.1])
plt.grid(True)
plt.show()

# 計算策略報酬率、市場報酬
sp500['Market'] = np.log(sp500['Close']/sp500['Close'].shift(1))  # sp500['Close'].shift(1) 整欄往下移一格 可print出來看看
sp500['Strategy'] = sp500['Regime'].shift(1) * sp500['Market']  # t-1的部位乘上t期的報酬

# 畫出策略Equity curve
sp500[['Market', 'Strategy']].cumsum().apply(np.exp).plot(grid=True, figsize=(9, 5))  # cumsum() 1 2 3 4 累加變成1 3 6 10的array； 
                                                                                      # apply(np.exp)用在dataframe 把每個值都取exp()還原  
plt.show()

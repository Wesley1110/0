import math
from numpy import *
from time import time


# Parameters
S0 = 100.
K = 105.
T = 1.0  # 年
r = 0.05
y = 0.0
sigma = 0.2  # 20%
M = 50       # 50步(每月價格:12步、每日價格:365步)
dt = T / M   # 1/50
I = 250000   # 25W條path


t0 = time()  # 目前系統時間
# Random seed
random.seed(20000)  # 亂數種子
# Simulating I paths with M time steps
S = S0 * exp(cumsum(((r-y) - 0.5 * sigma ** 2) * dt 
                    + sigma * math.sqrt(dt) * random.standard_normal((M, I)),   # M X I的陣列 row, col
                    axis=0))  # axis=0 對row cumsum

C0 = math.exp(-r * T) * sum(maximum(S[-1] - K, 0)) / I  # 計算選擇權期初的價格；S[-1]股價最後一筆(股票期末價格)；math.exp(-r * T) 折現
print("European Option Value %7.3f" % C0)
t1 = time()
print("Total Time: ", t1-t0)

len(S)  # 50 row

S       # 陣列 50 x 250000(無S0價格)

# 期初價格補S0
fst_row = zeros((1, I))  # 先創第一個row補0
for i in range(0, I):
    fst_row[0, i] = S0   # 第一個row補上S0
FullS = r_[fst_row, S]   # r_函數，讓fst_row, S兩個疊起來

FullS

# plot 模擬股價path(總共有25萬條path，驗證交易策略的有效性)
%matplotlib inline
import matplotlib.pyplot as plt

plt.figure(figsize=(9, 5))   # size
plt.plot(FullS[0:M+1, :10])  # 50期的價格、前10條path
plt.grid(True)
plt.xlabel('time step')
plt.ylabel('index level')
plt.title('Simulation Paths')
plt.show()

# Histogram 到期(期末)股價分布
plt.figure(figsize=(9, 5))
plt.hist(FullS[-1], bins=50)
plt.grid(True)
plt.xlabel('index level')
plt.ylabel('frequency')
plt.title('Maturity Stock Price Histogram')
plt.show()

# option in-the-money 機率圖(選擇權in-the-money到期價格分布)
plt.figure(figsize=(9, 5))
plt.hist(maximum(FullS[-1]-K, 0), bins=50)
plt.grid(True)
plt.xlabel('option inner value')
plt.ylabel('frequency')
plt.ylim(0, 50000)
plt.title('Option Inner Money Histogram')
plt.show()



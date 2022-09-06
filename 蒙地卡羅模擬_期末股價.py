import math
import numpy as np
import matplotlib.pyplot as plt

# 幾何布朗運動GBM，只模擬期末股價(講義5.2式)
S0 = 100.0
T = 1.0    # 1年
sig = 0.30
r = 0.025
y = 0.02
sig2 = sig*sig


np.random.seed(1234)
VecST = np.array(np.arange(1000))  # 期末stock price，模擬1000次(可調高至1W、10W)
for i in range(0, 1000):
    ST = S0 * math.exp((r-y-0.5*sig2)*T 
                       + sig*math.sqrt(T)*np.random.standard_normal())
    VecST[i] = ST
    

plt.figure(figsize=(9, 5))
plt.hist(VecST, bins=50)
plt.grid(True)
plt.xlabel('Price Level')
plt.ylabel('Frequency')
plt.title('Maturity Stock Price Histogram')
plt.show()


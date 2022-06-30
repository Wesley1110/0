import numpy as np
import sys
from matplotlib.pyplot import plot
from matplotlib.pyplot import show
%matplotlib inline

N = 5
# N = int(sys.argv[1])
# N = int(input("Average Period: "))
weights = np.ones(N) / N
print("Weights", weights)

c = np.loadtxt('data.csv', dtype='float', delimiter=',', usecols=(6,), unpack=True)
sma = np.convolve(weights, c)[N-1:-N+1]
print(len(c))

##
deviation = []
C = len(c)
for i in range(N - 1, C):
   if i + N < C:
      dev = c[i: i + N]
   else:
      dev = c[-N:]
   
   averages = np.zeros(N)
   averages.fill(sma[i - (N - 1)])
   dev = dev - averages
   dev = dev ** 2
   dev = np.sqrt(np.mean(dev))
   deviation.append(dev)

deviation = 2 * np.array(deviation)    # 2倍標準差
print(len(deviation), len(sma))
print(deviation)
print(sma)

##
upperBB = sma + deviation
lowerBB = sma - deviation
print(upperBB)

##
c_slice = c[N-1:]
between_bands = np.where((c_slice < upperBB) & (c_slice > lowerBB))    # 位置
print(lowerBB[between_bands])
print(c[between_bands])
print(upperBB[between_bands])

##  價格在布林通道中的比例有多少
between_bands = len(np.ravel(between_bands))    #  計算個數
print("Ratio between bands", float(between_bands)/len(c_slice))

#  plot
t = np.arange(N - 1, C)
plot(t, c_slice, lw=1.0)
plot(t, sma, lw=2.0)
plot(t, upperBB, lw=3.0)
plot(t, lowerBB, lw=4.0)
show()

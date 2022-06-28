import sys
import numpy as np
from matplotlib.pyplot import plot
from matplotlib.pyplot import show
%matplotlib inline

# N = int(sys.argv[1]) (sys的用途，從外部執行才要用)
# N = 5
N = int(input("Average Period: "))
weights = np.ones(N) / N
print("Weights", weights)

c = np.loadtxt('data.csv', dtype = 'float', delimiter=',', usecols=(6,), unpack=True)
sma = np.convolve(weights, c)[N-1:-N+1]  # convolve (捲積)運算
t = np.arange(N - 1, len(c))

plot(t, c[N-1:], lw=1.0)
plot(t, sma, lw=2.0)
show()

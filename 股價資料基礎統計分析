# load stock price data(CSV file, 7 column)
# stock, date, open, high, low, close, vol
import numpy as np
c, v = np.loadtxt('data.csv', delimiter=',', usecols=(6,7), unpack=True)  # 取第6,7個column

print(c)  # 30筆data
print(v)


# 計算VWAP(value weighted average price)，用vol當作權重計算價格加權平均數
vwap = np.average(c, weights = v)
print("VWAP = ", vwap)


print(np.max(c))  # maximum
print(np.min(c))  # minimum
print(np.median(c))  # median

sorted_close = np.msort(c)  # 排序
print(sorted_close)

print(np.var(c))  # variance

# 計算股票報酬率
# session (1) 傳統報酬率
import numpy as np
c = np.loadtxt('data.csv', delimiter=',', usecols=(6,), unpack=True) # len(c)=30(筆), 0...29
returns = np.diff(c) / c[:-1] # c[:-1] : 0~28不含最後一筆, diff(c)一階差分 : 0~28
print(c)
print(np.diff(c))  # 29筆data
print(c[:-1])      # 29筆data
print("Standard deviation =", np.std(returns))  # std

# session (2) 對數報酬率
logreturns = np.diff(np.log(c))
posretindices = np.where(returns>0) # Tuple 取得正報酬
print(logreturns)
print(posretindices)
print("Indices with positive returns", posretindices)

# 計算股票波動度(標準差)
daily_vol = np.std(logreturns)
annual_vol = daily_vol * np.sqrt(252.)  # 年化標準差
monthly_vol = annual_vol * np.sqrt(1./12.)
print("Daily volatility", daily_vol)
print("Monthly volatility", monthly_vol)
print("Annual volatility", annual_vol)

###################################
## WeekAnalysis 星期分析(星期效應)##
###################################
import numpy as np
from datetime import datetime

def datestr2num(ndary):    # 定義函數 日期格式轉星期
    lstdates = list(ndary)
    strdates = list()
    weekdates = list()
    num = len(lstdates)
    for i in range(num):
        strdates.append(str(lstdates[i]))
        weekdates.append(datetime.strptime(strdates[i], "%d-%m-%Y").date().weekday())  # 原日期格式 "%d-%m-%Y"            
    return weekdates


def pricestr2flt(ndary):    # price data轉float (原本是str)  
    lstprice = list(ndary)
    fltprice = list()
    strprice = list()
    num = len(lstprice)
    for i in range(num):
        strprice.append(str(lstprice[i]))
        fltprice.append(float(strprice[i]))
    return fltprice

# Monday 0, Tuesday 1, Wednesday 2, Thursday 3, Friday 4, Saturday 5, Sunday 6
nddates, ndclose = np.loadtxt('data.csv', dtype='str', delimiter=',', usecols=(1, 6), unpack=True)
print(nddates)
print(ndclose)

# 原本日期與價格都是str，現在執行先前定義的函式轉成我們要的格式
fltclose = list()
fltclose = pricestr2flt(ndclose)  # pricestr2flt 函式
print(fltclose)

weekdates = list()
weekdates = datestr2num(nddates)  # datestr2num 函式
print(weekdates)

# 列出每個(週一)的所有價格(週二、週三...週五)並計算平均數
averages = np.zeros(5)
ndweekdates = np.array(weekdates)
ndclose = np.array(fltclose)
for i in range(5):
    indices = np.where(ndweekdates == i)
    prices = np.take(ndclose, indices)
    avg = np.mean(prices)
    print("Day", i, "prices", prices, "Average", avg)
    averages[i] = avg

# 找出星期幾的平均價格最高    
top = np.max(averages)
print("Highest average", top)
print("Top day of the week", np.argmax(averages))

# 找出星期幾的平均價格最低
bottom = np.min(averages)
print("Lowest average", bottom)
print("Bottom day of the week", np.argmin(averages))

##########################
## Week Summary 完整週分析#
##########################

import numpy as np
from datetime import datetime

# Monday 0, Tuesday 1, Wednesday 2, Thursday 3, Friday 4, Saturday 5, Sunday 6
def datestr2num(ndary):
    lstdates = list(ndary)
    strdates = list()
    weekdates = list()
    num = len(lstdates)
    for i in range(num):
        strdates.append(str(lstdates[i]))
        weekdates.append(datetime.strptime(strdates[i], "%d-%m-%Y").date().weekday())
        nddates = np.array(weekdates)
    return nddates

def pricestr2flt(ndary):
    lstprice = list(ndary)
    fltprice = list()
    strprice = list()
    num = len(lstprice)
    for i in range(num):
        strprice.append(str(lstprice[i]))
        fltprice.append(float(strprice[i]))
        ndprice = np.array(fltprice)
    return ndprice

nddates, ndopen, ndhigh, ndlow, ndclose = np.loadtxt('data.csv', dtype='str', delimiter=',', \
    usecols=(1, 3, 4, 5, 6), unpack=True)  # 定義 column 1, 3, 4, 5, 6

dates = list()
dates = datestr2num(nddates)
open = list()
open = pricestr2flt(ndclose)
high = list()
high = pricestr2flt(ndhigh)
low = list()
low = pricestr2flt(ndlow)
close = list()
close = pricestr2flt(ndclose)

print(dates)  # output為數字0~4 週一到週五
print(open)
print(high)

# 只取其中前15筆data
close = close[:16]
dates = dates[:16]

# get first Monday 找出第一筆星期一的index
first_monday = np.ravel(np.where(dates == 0))[0]
print("The first Monday index is", first_monday)  # 1

# get last Friday 找出最後一個星期五的index
last_friday = np.ravel(np.where(dates == 4))[-1]
print("The last Friday index is", last_friday)  # 15

# 取出week index
weeks_indices = np.arange(first_monday, last_friday + 1)  # index 1~15 15天 = 3週 
print("Weeks indices initial", weeks_indices)  # [ 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15]

weeks_indices = np.split(weeks_indices, 3)  # 切分為3週
print("Weeks indices after split", weeks_indices)  # print出切分後的index

#  每一週的開高低收 o h l c
def summarize(a, o, h, l, c):
    monday_open = o[a[0]]              # a[0] 每一週的星期一
    week_high = np.max(np.take(h, a))  # 每一週取出最大值
    week_low = np.min(np.take(l, a))
    friday_close = c[a[-1]]
    return("APPL", monday_open, week_high, week_low, friday_close)

weeksummary = np.apply_along_axis(summarize, 1, weeks_indices, open, high, low, close)
print("Week summary", weeksummary)
np.savetxt("weeksummary.csv", weeksummary, delimiter=",", fmt="%s")


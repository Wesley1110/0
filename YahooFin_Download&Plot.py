import yfinance as yf
import pandas as pd

stock_id = 'GOOG'
data = yf.Ticker(stock_id)
historical_data = pd.DataFrame()
google = data.history(period='D', start='2019-1-1', end='2020-12-31')

google.head()
google.tail()

historical_data = pd.concat([historical_data, google])
historical_data.to_csv('Google_2019_2020.csv')  # save to csv file 

df = pd.read_csv('Google_2019_2020.csv', usecols=[0, 4], index_col=0, parse_dates=True)

df.head()
df.tail()

# plot time series
import matplotlib.pyplot as plt
import seaborn
seaborn.set()
df.plot()


# method 2.

import yfinance as yf
import pandas as pd

stock_id = 'GOOG'
data = yf.Ticker(stock_id)
google = data.history(period='D', start='2019-1-1', end='2020-12-31')

google.head()

## save to csv file 
google.to_csv('google.csv')
df = pd.read_csv('google.csv', usecols=[0, 4], index_col=0, parse_dates=True)

df.head()


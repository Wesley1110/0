import pandas as pd
import yfinance as yf

data = yf.Ticker('^GSPC')    #  sp500
sp = data.history(period='D', start='2015-1-1', end='2016-5-30')
print(sp.info())

sp.head(10)

data = yf.Ticker('IBM')
ibm = data.history(period='D', start='2015-1-1', end='2016-5-30')
ibm.head(10)

h5 = pd.HDFStore('2015_SP_IBM.h5', complevel=9, complib='blosc')
h5['ibm_stock'] = ibm
h5['sp_stock'] = sp
h5.close()


#  read HDF5 file
import pandas as pd
sp_df = pd.read_hdf('2015_SP_IBM.h5', 'sp_stock')
sp_df.head()

ibm_df = pd.read_hdf('2015_SP_IBM.h5', 'ibm_stock')
ibm_df.head()


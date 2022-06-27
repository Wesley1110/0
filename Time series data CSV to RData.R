# method 1. Time series CSV檔 第一個column轉成時間戳記再轉成 RData file

library(xts) # 載入xts套件 #
data0=read.csv("C:\\....Location\\Close.csv") # 載入外部資料 Transform time series data into time series object
timeID= as.Date(data0[,1]) # 將第1欄轉成時間戳記 #
data1=data0[,-1] # 將時間欄移除的新資料，只保留價格數據 #
xtsClose=as.xts(data1, timeID) # 轉換成 xts 時間格式 #
save(xtsClose, file="C:\\....Location\\Close.RData") # 存成 .RData 格式，大功告成了 #


# method 2. Time series CSV檔(特例) 第一個column的日期是連續數字 EX:19961110 

library(timeSeries)

temp0=read.csv("C:\\....Location\\49_Industry_VWP.CSV")
dateID0=as.character(temp0[,1])  # 第一欄原本數字轉成character
year=substr(dateID0,1,4)  # 第1~第4個數字為year
month=substr(dateID0,5,6)
day=substr(dateID0,7,8)
dateID=as.Date(as.character(paste(year,month,day,sep="-")))
temp=temp0[,-1]
rownames(temp)=dateID
assetReturns=as.timeSeries(temp)
save(assetReturns,file="dataVWP49.RData")

# method 3. similar with method 2. 

temp=read.csv("C:\\....Location\\49_Industry_VWP.csv") 
head(temp)
dateID0=temp[,1]
year=substr(dateID0,1,4)
month=substr(dateID0,5,6)
day=substr(dateID0,7,8)
dateID=as.Date(as.character(paste(year,month,day,sep="-")))
returnsRaw=temp[,-1]
rownames(returnsRaw)=dateID
assetReturns=as.timeSeries(returnsRaw)
save(assetReturns,file="dataVWP49.RData")


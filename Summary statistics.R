## Case 1. data 全都是數字才行
dataUsed1=read.csv("tips.csv")
head(dataUsed1)
tail(dataUsed1)

library(fBasics)
summary=basicStats(dataUsed1)    #  會出錯，因為有部分column是文字
write.csv(summary,file="C:\\....\\Summary statistics.csv")    #  Save output

## Case 2. 
library(fBasics)
X=dataUsed1[,1:2]    #  只選 column 1,2
basicStats(X)
write.csv(X,file="C:\\....\\Summary statistics.csv")    #  Save output


source("trainingSamples.R")  # load function
library(caret)

dataset=read.csv("vote.csv")

dataset$subSample = trainingSamples(dataset, Training=0.75, Validation=0)  # 新增subSample欄位
table(dataset$subSample)
dim(dataset)
trainData=subset(dataset,subSample=="Training")[,-6]
testData=subset(dataset,subSample=="Testing")[,-6]
table(trainData$vote)
Eq=as.formula("vote ~ .")

#Topic 1. Using independent libraries
# 1. glm 
fit.glm=glm(Eq, family=binomial(link="logit"),data=trainData)  # 從train data中建一個logit model
summary(fit.glm)

Prob1.glm=predict(fit.glm,type = "response", newdata=trainData)  # 預測機率
summary(Prob1.glm)
boxplot(Prob1.glm)
Pred1.glm=ifelse(Prob1.glm>=0.5,1,0)  # 定義大於0.5為1(成功))

CFMatrix1.glm=table(Actual = trainData[,"vote"], Predicted =Pred1.glm)  #Confusion matrix

confusionMatrix(CFMatrix1.glm) #function of library(caret)

as.matrix(confusionMatrix(CFMatrix1.glm),what="overall")
as.matrix(confusionMatrix(CFMatrix1.glm),what="classes")

#===Problem 1. Please complete the confusionMatrix of Prob2.glm by testData

Prob2.glm=predict(fit.glm,type = "response", newdata=testData)
summary(Prob2.glm)
boxplot(Prob2.glm)
Pred2.glm=ifelse(Prob2.glm>=0.5,1,0)

CFMatrix2.glm=table(Actual = testData[,"vote"], Predicted =Pred2.glm)  #Confusion matrix

as.matrix(confusionMatrix(CFMatrix2.glm),what="overall")
as.matrix(confusionMatrix(CFMatrix2.glm),what="classes")


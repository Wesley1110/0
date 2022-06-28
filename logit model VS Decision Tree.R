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

confusionMatrix(CFMatrix2.glm)

as.matrix(confusionMatrix(CFMatrix2.glm),what="overall")
as.matrix(confusionMatrix(CFMatrix2.glm),what="classes")

# 2. Decision Tree with library(rpart) 決策樹 using rpart
library(rpart)
trainData$vote=as.factor(trainData$vote)

fit.tree=rpart(Eq, data=trainData, cp=0.01)

dev.new();rattle::fancyRpartPlot(fit.tree,sub=NULL,palettes=c("Greys", "Oranges")[2],type=1) 

Prob1.tree =predict(fit.tree,trainData)
Pred1.tree=apply(Prob1.tree,1,which.max)-1

CFMatrix1.tree=table(Actual = trainData[,"vote"], Predicted =Pred1.tree)  #Confusion matrix

confusionMatrix(CFMatrix1.tree)

#===Problem 2. Please compare the predictive performance of glm and decision tree 
Prob2.tree =predict(fit.tree,testData)
Pred2.tree=apply(Prob2.tree,1,which.max)-1

CFMatrix2.tree=table(Actual = testData[,"vote"], Predicted =Pred2.tree)  #Confusion matrix

confusionMatrix(CFMatrix2.tree)

#Topic 2. Using library(caret) 決策樹 using caret
models=c("glm","rpart","svmRadial","rf","glmboost","gafs")
m=2
output=train(Eq, data=trainData, method=models[m],tuneLength = 20)

##Predict the train data
Pred1 =as.integer(predict(output,trainData,type=c("raw","prob")[1]))-1

CFMatrix1=table(Actual = trainData[,"vote"], Predicted =as.factor(Pred1))  #Confusion matrix
confusionMatrix(CFMatrix1)

##Predict the test data
Pred2 =as.integer(predict(output,testData,type=c("raw","prob")[1]))-1

CFMatrix2=table(Actual = testData[,"vote"], Predicted =as.factor(Pred2))  #Confusion matrix

confusionMatrix(CFMatrix2)

as.matrix(confusionMatrix(CFMatrix2),what="overall")
as.matrix(confusionMatrix(CFMatrix2),what="classes")

round(rbind(as.matrix(confusionMatrix(CFMatrix2),what="overall"),        # 兩個結果按照row併再一起，取小數點3位
            as.matrix(confusionMatrix(CFMatrix2),what="classes")),3)



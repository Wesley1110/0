####################################################################
# Section 1:  Fitting Classification Tress                         #
####################################################################

## Growing a Tree
library(tree)
library(ISLR)
attach(Carseats) 
Carseats # This is a simulated data set containing sales of child car seats at 400 different stores.

High=ifelse(Sales<=8,"No","Yes") # turn the sales variable to a binary response.
High=as.factor(ifelse(Sales<=8,"No","Yes")) # 加上as.factor才對
Carseats=data.frame(Carseats,High) 
tree.carseats=tree(High~.-Sales,Carseats, split = "gini", mincut = 5)  # We fit "High" on the "Carseats" data set without "Sales"
# Note that the tree() function is very similar to lm().
# Here we use Gini index as the splitting criterion.

# "mincut" is the splitting criteria for this classification tree, and is defaulted to be 5.
# "mincut" determines the minimum number of observations required for each class. For instance, suppose that we 
# have 14 observations in a node and are deciding whether to split it or not. If 11 are in class A and only 4 in class B then 
# the code wouldn't split because it doesn't have at least 5 of each class. 

summary(tree.carseats) 
# Note that the variables used in tree building are "Advertising" "Price"  "ShelveLoc" "CompPrice"  "Age"  "Income" "Education".
# Note that the misclassification error rate for this tree is 11.5% (46 out of 400 observations are wrongly classified).


plot(tree.carseats,  type = "proportional") # If type = "uniform", the branches are of uniform length. Otherwise they are proportional to the decrease in impurity.
text(tree.carseats,pretty=0)
tree.carseats

##Evaluate a tree using a testing data
set.seed(10)
train=sample(1:nrow(Carseats), nrow(Carseats)/2)
Carseats.test=Carseats[-train,]
High.test=High[-train]
tree.carseats = tree(High~.-Sales, Carseats, subset=train, split = "gini") # A tree built using only the training set.
tree.pred=predict(tree.carseats,Carseats.test,type="class") # Using the tree to predict the testing data
table(tree.pred,High.test)
(87+45)/200 # 66% of correct prediction rate on the test set.


## Tree pruning
set.seed(10)
cv.carseats=cv.tree(tree.carseats, FUN=prune.misclass ,K = 100) 
# "FUN=prune.misclass" indicates that we use classification error rate to guide the pruning process.
# Here we perform a 100-fold CV.

names(cv.carseats)
plot(cv.carseats) # Here we see the misclassicifations for different size.

cv.carseats # Note that the "dev" represents the CV error rate.
# "k" represents the "alpha" we used in class, which is the tuning parameter of tree complexity.
# "size" is the number of terminal nodes of each tree considered.
# Here we can see that the optimal tree has "7" terminal nodes.

par(mfrow=c(1,2)) # Here we plot the CV error rate against "k" and "size"
plot(cv.carseats$size,cv.carseats$dev,type="b")
plot(cv.carseats$k,cv.carseats$dev,type="b")


prune.carseats = prune.misclass(tree.carseats,best=7) # We now create the pruned tree with 7 leaves (terminal nodes), which is shown to have the smallest cv error rate.
plot(prune.carseats)
text(prune.carseats,pretty=0)

tree.pred = predict(prune.carseats, Carseats.test, type="class")
table(tree.pred,High.test)
(92+41)/200 # 66.5% of correct prediction rate on the test set, which is a bit better than the unpruned tree, and it also gains much more interpretability.

par(mfrow=c(1,1))
####################################################################
# Section 2:  Fitting Regression Tress                             #
####################################################################
rm(list=ls(all=T))


library(MASS)
library(tree)

## Growing a Tree
Boston # Housing Values in Suburbs of Boston

set.seed(1)
train = sample(1:nrow(Boston), nrow(Boston)/2)    # 506 253
tree.boston=tree(medv~.,Boston,subset=train) # "medv" is the median value of owner-occupied homes in $1000s.
summary(tree.boston) 
# Note that it uses 4 variavles in constructing the tree.
# For regression trees, the deviance refers to the sum of squared errors and = 2555 for this tree.

plot(tree.boston)
text(tree.boston,pretty=0)

## Tree pruning
set.seed(1)
cv.boston=cv.tree(tree.boston, K=100) 
cv.boston
plot(cv.boston$size,cv.boston$dev,type='b') # Here we see that the most complex tree is chosen. There for prunning is not necessary.


# Evaluate the tree 
prune.boston=prune.tree(tree.boston,best=5) # Here we construct a pruned tree with 5 terminal nodes.

yhat = predict(tree.boston,newdata=Boston[-train,]) # Fitted value for the unpruned tree on testing data.
yhat.prune = predict(prune.boston,newdata=Boston[-train,])  # Fitted value for the pruned tree on testing data.

boston.test=Boston[-train,"medv"]

plot(yhat,boston.test)
abline(0,1) # If predictions were perfect, all the data would be right on this line
mean((yhat-boston.test)^2) # Estimated testing MSE for the unpruned tree = 35.28688

plot(yhat.prune,boston.test)
abline(0,1)    # 0,1 the intercept and slope
mean((yhat.prune-boston.test)^2) # Estimated testing MSE for the pruned tree = 35.90102, which shows that it is indeed worse than the full tree.


####################################################################
# Section 3: Bagging and Random Forests                            #
####################################################################

rm(list=ls(all=T))
#############
## Bagging ##
#############

library(randomForest)
library(MASS)

set.seed(1)
train = sample(1:nrow(Boston), nrow(Boston)/2)

set.seed(1)
bag.boston=randomForest(medv~., data=Boston, subset=train, mtry=(ncol(Boston)-1), ntree=500,importance=TRUE)
# The argument "mtry=(ncol(Boston)-1)" means that all 13 independent variables should be considered for each split of the each tree, which is the definition of bagging.
# "ntree=500" is the defualt value, which means we bootstrap the sample 500 times.
# "importance=TRUE" assess the importance of predictors, the defualt is FALSE.

bag.boston

## Evaluate the result
#How well does this bagged model perform on testing data? let's find out through the following codes.
yhat.bag = predict(bag.boston,newdata=Boston[-train,])
boston.test=Boston[-train,"medv"]

plot(yhat.bag, boston.test)
abline(0,1) # If predictions were perfect, all the data would be right on this line
mean((yhat.bag-boston.test)^2)
# This yield an estimated testing MSE of 23.59273, which is much smaller than what we obtained form optimally pruned single tree :35.28688


importance(bag.boston)
# "%IncMSE" represents the mean decrease of accuracy in predictions on the out of bag samples when a given variable is excluded from the model.
# "IncNodePurity" represents the total decrease in node impurity that results form the splits using that variable, averaged over all trees.  For classification, the node impurity is measured by the Gini index. For regression, it is measured by residual sum of squares.

varImpPlot(bag.boston) # plot of variable importance.

## We now change the bootstrap grown tree from 500 to 5
set.seed(1)
bag.boston=randomForest(medv~., data=Boston, subset=train, mtry=(ncol(Boston)-1), ntree=5,importance=TRUE)
yhat.bag = predict(bag.boston,newdata=Boston[-train,])
mean((yhat.bag-boston.test)^2)
# This yield an estimated testing MSE of 24.10238, which is worse off than the bagging model with 500 trees.



####################
## Random Forests ##
####################

# Compare to bagging, random forest proceeds in the exact same way, except that we use a samller value for "mtry"
# By default, randomForest() chooses m=p/3 when building a random forest of regression trees, 
# while choosing m=sqrt(p) when building a random forest of classification trees.

set.seed(1)
rf.boston=randomForest(medv~.,data=Boston,subset=train,mtry=4,importance=TRUE) # Here we choose m=4, everything else is equal.

## Evaluate the result
yhat.rf = predict(rf.boston,newdata=Boston[-train,])
mean((yhat.rf-boston.test)^2) # We see that the estimated testing MSE drop further from 23.59273(for bagging) to 18.11686.

# plot of variable importance.
importance(rf.boston)
varImpPlot(rf.boston)



###############
## OOB error ##
###############

# We divide the data set to a testing and training set, so that we can compare the test MSE among a single tree, bagging, random forest, and boosting.
# But recall that for bagging and boosting, we can estimate the test MSE by the out-of-bag approach.
# We now calculate the out-of-bag error for bagging and random forest using the complete data set.

set.seed(1)
bag.boston=randomForest(medv~., data=Boston, mtry=(ncol(Boston)-1))

set.seed(1)
rf.boston=randomForest(medv~., data=Boston, mtry=4) # Here we choose m=4, everything else is equal.

bag.boston$mse # These are the OOB error of the bagging model for each given number of trees.
               # For the case of a classification tree, the OOB error are stored in the first column in "$err.rate" instead of "$mse".

rf.boston$mse # These are the OOB error of random forest for each given number of trees.


plot(bag.boston$mse, type = "l", xlab = "Number of Trees", ylab = "OOB error", cex.lab = 1.2, col="blue") # OOB error for bagging
a =length(rf.boston$mse)
lines(seq(from = 1,to = a, length =a), rf.boston$mse, col = "red") # OOB error for random forest
legend("topright",legend = c("Bagging", "Random Forest"),col = c("blue", "red"), lty = c(1, 1))

# Here we can see that the OOB error decrease drastically when the number of bootstrap trees start to grow.
# Moreover, the random forest slightly outperformed the bagging model



###########################################################################
# Section 4: Boosting  (Gradient Boosting for Regression Trees (residuals)#
###########################################################################

library(gbm)
library(MASS)

set.seed(1)
train = sample(1:nrow(Boston), nrow(Boston)/2)

set.seed(1)
boost.boston = gbm(medv~., data=Boston[train,], distribution="gaussian", n.trees=1000, interaction.depth=4, shrinkage = 0.1, bag.fraction = 1, cv.folds=10)
# "distribution=gaussian" is used in a regression problem. If it were a classification problem, "distribution=bernoulli" should be used.
# "interaction.depth=4" limits the depth of each tree to be 4.
# "shrinkage = 0.1" indicates that the shrinkage parameter "lambda" for each tree is 0.1
# "bag.fraction = 1" indicates that we use all the data in "data=Boston[train,]", if "bag.fraction = 0.5", as defaulted, then it will choose only half the data from "data=Boston[train,]".
# "cv.folds=10" indicates the number of cross-validation folds to perform.

summary(boost.boston)
#this returns the reduction of squared error attributable for each variable. It describes the relative influence of each variable in reducing the loss function.

boost.boston$cv.error # This returns the 10-fold CV error for each number of trees. 
A = which.min(boost.boston$cv.error) # which shows that number of trees = 513 yields the optimal results.

## Evaluate the result
set.seed(1)
boost.boston = gbm(medv~., data=Boston[train,], distribution="gaussian", n.trees=A, interaction.depth=4, shrinkage = 0.1, bag.fraction = 1)
yhat.boost=predict(boost.boston,newdata=Boston[-train,],n.trees=A)
mean((yhat.boost-boston.test)^2) # This yield an estimated testing MSE of 17.24298, which is even smaller than that of bagging (23.59273) and random forest (18.11686).

# We can try performing boosting using differet pair of "n.trees, interaction.depth, shrinkage"
set.seed(1)
boost.boston=gbm(medv~.,data=Boston[train,],distribution="gaussian",n.trees=10000,interaction.depth=2,shrinkage=0.01)
yhat.boost=predict(boost.boston,newdata=Boston[-train,],n.trees=10000)
mean((yhat.boost-boston.test)^2) # Which yields a slightly worse off result.



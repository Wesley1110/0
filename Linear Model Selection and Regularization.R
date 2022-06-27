Linear Model Selection and Regularization ( R code )

####################################################################
# Section 1: Subset Selection Methods                              #
####################################################################

Theft= read.csv("theft.csv")
head(Theft)
ncol(Theft) # There are 16 regressors and 1 response. ( 17 column,  the first one is Y)
nrow(Theft) # There are 209 samples.
dim(Theft)  # row, column (209, 17)

#########################
# Best Subset Selection #
#########################

library(leaps)
best.fit = regsubsets(theft~.,Theft,nvmax=16) # "nvmax" is the maximum size of subsets we wish to examine
summary.fit = summary(best.fit) 
summary.fit   # Note that the "*" represents which variable is chosen in which model. 
              # For example, for the "best one variable" model, the model chooses "non_workforce".
par(mfrow=c(1,2))
plot(summary.fit$bic, lwd=2, xlab = "Number of Variables", ylab = "BIC", type = "l", cex.lab=1.3)
a=which.min(summary.fit$bic)
points(a,summary.fit$bic[a], col="red", cex=2, pch=20)
which.min(summary.fit$bic) # As we can see, the samllest BIC corresponds to the model with 8 variables.

plot(summary.fit$cp, col="steelblue", lwd=2,xlab = "Number of Variables", ylab = "Cp", type = "l")
b=which.min(summary.fit$cp)
points(b,summary.fit$cp[b], col="red", cex=2, pch=20)
which.min(summary.fit$cp) # The samllest Cp also corresponds to the model with 8 variables.

coef(best.fit,8) # Here's the best model and its chosen coefficients.
par(mfrow=c(1,1))

###########################################
# Forward and Backward Stepwise Selection #
###########################################

forward.fit = regsubsets(theft~.,Theft,nvmax=16,method = "forward") # The codes are the same, except we now pass-in the code "method = "forward" "
summary(forward.fit)
which.min(summary(forward.fit)$bic) # Forward stepwise picks the model with 9 variables
coef(forward.fit,9) #Forward method selects "umemploy_ppl" in the 5th round, which is not selected by other methods.

backward.fit = regsubsets(theft~.,Theft,nvmax=16,method = "backward")
summary(backward.fit)
which.min(summary(backward.fit)$bic)
coef(backward.fit,8) # Note that it's exactly the same as best subset.


####################################################################
# Section 2: Ridge Regression and LASSO                            #
####################################################################

rm(list=ls(all=T))
Theft= read.csv("theft.csv")

X = model.matrix(theft~.,Theft)[,-1] # 把第一欄刪掉，第一個column是Y。
Y= Theft$theft
library(glmnet)


####################
# Ridge Regression #
####################
grid = seq(0,100,length = 1000)  # 數字0~100切等分1000個數

ridge.fit = glmnet(X,Y,alpha = 0, lambda = grid) # "alpha" = 0 for ridge regression, =1 for Lasso
                                                 # Since the "lambda" is specified, so the code search for the optimal lambda in "grid"

dim(coef(ridge.fit)) # 17個變數(含截距項) 1個lambda值會有一組17個變數的coef，1000個lambda value就會有1000組coef
ridge.fit$lambda[1]  # The first lambda used is 100
ridge.fit$lambda[999]# The 999th lambda used is 0.1001001

coef(ridge.fit)[,1]   # This corresponds to lambda = 100, which yields small coefficients. ## 第一筆lambda是100，lambda愈大使得係數shrink toward 0.
coef(ridge.fit)[,999] # This corresponds to lambda = 0.1001001, which yields bigger coefficients.

##coeffiecent plot
plot(ridge.fit$lambda ,coef(ridge.fit)[2,],type="l",ylim =c(-5,9), xlim = c(0,100)) # This is the plot of the coefficient of the first variable (beta_1) against different lambda.
                                                                                    # Note that "coef(ridge.fit)[1,]" corresponds to the coefficient of intercept, which we don't care.
                                                                                    # 截距項 + 16個變數有1~17，不考慮1就是2~17。
lines(rep(0,100),col='red')

plot(ridge.fit$lambda ,coef(ridge.fit)[2,],type="l",ylim =c(-1500,1500), xlim = c(0,100)) 
lines(rep(0,100),col='red',lw=5)
for (i in 3:17){
  lines(ridge.fit$lambda,coef(ridge.fit)[i,])} # Here we plot the rest of the betas.

##predict for specific lambda ex. lambda=50
predict(ridge.fit, s=50,type="coefficients")


##Choosing the optimal lambda with k-fold CV
set.seed(45)
ridge.kfold = cv.glmnet(X,Y,alpha=0, nfolds=10, lambda = grid)
best.s = ridge.kfold$lambda.min 
best.s 

##Fitted values for the optimal lambda
predict(ridge.fit, type = "coefficients", s=best.s) # Fitted values for optimal lambda.

#########
# LASSO #
#########
grid = seq(0,100,length = 1000)

lasso.fit = glmnet(X,Y,alpha = 1, lambda = grid) # "alpha" = 0 for ridge regression, =1 for Lasso

dim(coef(lasso.fit)) # Each column contains the estimated coefficeint for 67 different lambda values chosen by computer.
lasso.fit$lambda[1]  # The first lambda used is 100
lasso.fit$lambda[999]# The 999th lambda used is 0.1001001

coef(lasso.fit)[,1]   # This corresponds to lambda = 100, which forces 8 variables to be zero
coef(lasso.fit)[,999] # This corresponds to lambda = 0.1001001

##coeffiecent plot
plot(lasso.fit$lambda ,coef(lasso.fit)[2,],type="l",ylim =c(-1000,1000) )
for (i in 3:17){
  lines(lasso.fit$lambda ,coef(lasso.fit)[i,])}
##

##Choosing the optimal lambda with k-fold CV
set.seed(45)
lasso.kfold = cv.glmnet(X,Y,alpha=1, nfolds=10, lambda = grid)
best.s = lasso.kfold$lambda.min 
best.s 

##Fitted values for the optimal lambda
predict(lasso.fit, type = "coefficients", s=best.s)

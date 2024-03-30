# constructing data ; Simulate the data with b0=0.5, b1=0
n=100
x = rnorm(n, mean=0, sd=1)

# epsilon with normal dis.
epsilon = rnorm(n, mean=0, sd=5)
# epsilon with heteroskedasticity
epsilon = rnorm(n, mean=0, sd=1 + abs(x))
# epsilon with auto-correlated
epsilon = arima.sim(model=list(order=c(1,0,0), ar=0.7), n=n)

y = 0.5 + 0*x + epsilon

# Now in order to test the coefficients, we first has to install the package "lmtest"
library(lmtest) # call the package
lm.fit = lm(y~x)
coeftest(lm.fit) # IID assumptions(residuals)

# First we need to install the package "car"
# Now we wish to test "b1=0", the following code will do the trick
library(car)
library(sandwich)
# For the test "b1=0" without the robust standard errors.
linearHypothesis(lm.fit,c("x = 0"))  # if 結果顯著拒絕H0，表示此假設(b1=0)是錯的。

# Robust t test
vcovHC(lm.fit, type = "HC0")  # "HC0" gives White’s estimator. Long & Ervin (2000) conduct a simulation study of 
                              # HC estimators (HC0 to HC3) in the linear regression model, 
                              # recommending to use HC3 which is thus the default in vcovHC.
                              # 這是 Robust std.後的variance covariance matrix
                                    
coeftest(lm.fit, vcov = vcovHC(lm.fit, type = "HC0")) # 這是 Robust std.的迴歸結果 

# For the test "b1=0" with the robust standard errors.
linearHypothesis(lm.fit, c("x = 0"), vcov = vcovHC(lm.fit, type = "HC0"))  # if 結果顯著拒絕H0，表示此假設(b1=0)是錯的。

# HAC Standard errors (當殘差有自我相關)
# The package sandwich also contains the function NeweyWest(), 
# an implementation of the HAC variance-covariance estimator proposed by Newey and West (1987).
NeweyWest(lm.fit)
coeftest(lm.fit, vcov = NeweyWest(lm.fit))
# For the test "b1=0" with the robust standard errors.
linearHypothesis(lm.fit, c("x = 0"), vcov = NeweyWest(lm.fit))






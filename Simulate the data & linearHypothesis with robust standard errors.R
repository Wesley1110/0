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



# Estimate the parameters with OLS and test the hypothesis(b1=0),with and without the robust standard errors. In each simulation,
# record if the test statistics reject the null or not. Repeat the simulation 1,000 times and report the average
# rejection rate for each types of tests.

# Set the number of simulations
num_simulations <- 1000
# Initialize rejection counts
reject_count_without_robust <- 0
reject_count_with_robust <- 0

# Perform simulations and hypothesis tests
for (i in 1:num_simulations) {
  # Generate data
  x <- rnorm(n, mean=0, sd=1)
  epsilon <- rnorm(n, mean=0, sd=1 + abs(x))
  y <- 0.5 + 0*x + epsilon
  
  # Fit the linear model
  lm.fit <- lm(y ~ x)
  
  # Perform hypothesis test without using robust standard errors
  test_without_robust <- linearHypothesis(lm.fit, "x = 0")
  # Record rejection if at least one p-value is less than 0.05
  if (any(!is.na(test_without_robust$"Pr(>F)") & test_without_robust$"Pr(>F)" < 0.05)) {
    reject_count_without_robust <- reject_count_without_robust + 1
  }
  
  # Perform hypothesis test using robust standard errors
  robust_se <- vcovHC(lm.fit, type = "HC0")
  test_with_robust <- linearHypothesis(lm.fit, "x = 0", vcov = robust_se)
  # Record rejection if at least one p-value is less than 0.05
  if (any(!is.na(test_with_robust$"Pr(>F)") & test_with_robust$"Pr(>F)" < 0.05)) {
    reject_count_with_robust <- reject_count_with_robust + 1
  }
}

# Compute average rejection rates
average_rejection_rate_without_robust <- reject_count_without_robust / num_simulations
average_rejection_rate_with_robust <- reject_count_with_robust / num_simulations

# Output results
average_rejection_rate_without_robust  # output: 0.159
average_rejection_rate_with_robust     # output: 0.065 with robust std.的情況下，結果較為正確。





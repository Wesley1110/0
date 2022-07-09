# method provided by professor Ho
path="C:\\suicideoverviews.csv"
temp=read.csv(path)
Y=temp$countryYear

stringr::str_replace_all(Y,pattern="\\d","")

stringr::str_sub(Y,-4,-1)
stringr::str_sub(Y,1,-5)

t1="[[:digit:]]+"
t2="[[:alpha:]]+"
stringr::str_extract(Y,t1)
stringr::str_extract(Y,t2)

readr::parse_number(Y)

gsub(Y,pattern="[1234567890]+",replacement="")
gsub(Y,pattern="[A-Za-z]+",replacement="")

tidyr::separate(temp,countryYear, into=c("country","Year"),sep=-4)
tidyr::separate(temp,countryYear, into=c("country","Year"),sep="(?<=[A-Za-z])(?=[0-9])")


as.numeric(gregexpr("[0-9]+",Y))

# method 2. 
library(tidyr)

data=read.csv("C:\\suicideoverviews.csv")

new_data <- data %>% 
            separate(countryYear, into = c("country", "Year"), 
            sep = "(?<=[A-Za-z])(?=[0-9])"
  )
  
  

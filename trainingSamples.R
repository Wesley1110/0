trainingSamples <- function (x, Training = 0.34, Validation = 0.33, rand.seed = 1) 
{
  if ((Training + Validation) > 1) 
    stop("The estimation and validation samples exceed 100%.")
  if (Training < 0 | Validation < 0) 
    stop("A negative sample size was provided.")
  nEst <- round(Training * nrow(x))
  nVal <- round(Validation * nrow(x))
  if ((nEst + nVal) < nrow(x)) {
    assignmnts <- c(rep("Training", nEst), rep("Validation", 
                                               nVal), rep("Testing", (nrow(x) - nEst - nVal)))
  }
  else {
    assignmnts <- c(rep("Training", nEst), rep("Validation", 
                                               nVal))
  }
  set.seed(rand.seed)
  randVar <- runif(nrow(x))
  assignmnts <- assignmnts[order(randVar)]
  return(assignmnts)
}



rank.Score <- function (model, data, targLevel) 
{
  mod <- eval(parse(text = model))
  modtype <- class(mod)[1]
  if (modtype != "glm" & modtype != "rpart" & modtype != "nnet.formula") {
    stop("Scoring can only be done for models estimated using glm, rpart, or nnet.")
  }
  yvar <- as.character(mod$call$formula)[2]
  origYs <- eval(parse(text = paste("unique(", "data$", yvar, ")")))
  origYs <- as.character(origYs)
  origYs <- origYs[order(origYs)]
  xvars <- unlist(strsplit(as.character(mod$call$formula)[3], 
                           " + ", fixed = TRUE))
  if (!all(xvars %in% names(data))) {
    probVar <- c(xvars[!(xvars %in% names(data))])
    stop(paste("The model variables", paste(probVar, collapse = ", "), 
               "are not in the data set."))
  }
  modelReDo <- eval(mod$call)
  if (modtype == "glm" | modtype == "nnet.formula") {
    if (origYs[1] == targLevel) {
      scoreVar1 <- -1 * predict(modelReDo, newdata = data)
    }
    else {
      scoreVar1 <- predict(modelReDo, newdata = data)
    }
  }
  else {
    scoreVar1 <- predict(modelReDo, newdata = data)[, targLevel]
  }
  score.df <- data.frame(scoreVar = 1:nrow(data), oldOrd = order(scoreVar1, 
                                                                 decreasing = TRUE))
  score.df <- score.df[order(score.df$oldOrd), ]
  scoreVar <- score.df$scoreVar
  return(scoreVar)
}


adj.ProbScore<- function (model, data, targLevel, trueResp) 
{
  mod <- eval(parse(text = model))
  modtype <- class(mod)[1]
  if (modtype != "glm" & modtype != "rpart" & modtype != "nnet.formula") {
    stop("Scoring can only be done for models estimated using glm, rpart, or nnet.")
  }
  yvar <- as.character(mod$call$formula)[2]
  yvar1 <- eval(parse(text = paste("as.character(", "data$", yvar, ")")))
  yvar2 <- as.numeric(yvar1 == targLevel)
  print(yvar1)
  sampResp <- sum(yvar2)/length(yvar2)
  adjWt <- trueResp/sampResp
  origYs <- eval(parse(text = paste("unique(", "data$", yvar, ")")))
  origYs <- as.character(origYs)
  origYs <- origYs[order(origYs)]
  xvars <- unlist(strsplit(as.character(mod$call$formula)[3], 
                           " + ", fixed = TRUE))
  if (!all(xvars %in% names(data))) {
    probVar <- c(xvars[!(xvars %in% names(data))])
    stop(paste("The model variables", paste(probVar, collapse = ", "), 
               "are not in the data set."))
  }
  modelReDo <- eval(mod$call)
  if (modtype == "glm" | modtype == "nnet.formula") {
    if (origYs[1] == targLevel) {
      scoreVar1 <- -1 * predict(modelReDo, newdata = data)
    }
    else {
      scoreVar1 <- predict(modelReDo, newdata = data)
    }
  }
  else {
    scoreVar1 <- predict(modelReDo, newdata = data)[, targLevel]
  }
  if (modtype == "glm") {
    scoreVar <- adjWt * (exp(scoreVar1)/(exp(scoreVar1) + 
                                           1))
  }
  else {
    scoreVar <- adjWt * scoreVar1
  }
  return(scoreVar)
}


raw.ProbScore<-function (model, data, targLevel) 
{
  mod <- eval(parse(text = model))
  modtype <- class(mod)[1]
  if (modtype != "glm" & modtype != "rpart" & modtype != "nnet.formula") {
    stop("Scoring can only be done for models estimated using glm, rpart, or nnet.")
  }
  yvar <- as.character(mod$call$formula)[2]
  origYs <- eval(parse(text = paste("unique(", "data$", yvar, ")")))
  origYs <- as.character(origYs)
  origYs <- origYs[order(origYs)]
  xvars <- unlist(strsplit(as.character(mod$call$formula)[3], 
                           " + ", fixed = TRUE))
  if (!all(xvars %in% names(data))) {
    probVar <- c(xvars[!(xvars %in% names(data))])
    stop(paste("The model variables", paste(probVar, collapse = ", "), 
               "are not in the data set."))
  }
  modelReDo <- eval(mod$call)
  if (modtype == "glm" | modtype == "nnet.formula") {
    if (origYs[1] == targLevel) {
      scoreVar1 <- -1 * predict(modelReDo, newdata = data)
    }
    else {
      scoreVar1 <- predict(modelReDo, newdata = data)
    }
  }
  else {
    scoreVar1 <- predict(modelReDo, newdata = data)[, targLevel]
  }
  if (modtype == "glm") {
    scoreVar <- exp(scoreVar1)/(exp(scoreVar1) + 1)
  }
  else {
    scoreVar <- scoreVar1
  }
  return(scoreVar)
}

install.packages("xlsx")
library(xlsx)
data <- read.xlsx("Alchemy Broker Data.xlsx", 1)

names(data)<-c("brokerid","brokername","policycount1","policycount2","policycount3","policycount4","policycount5","policycount6","GWP1","GWP2","GWP3","GWP4","GWP5","GWP6",
               "Quotes1","Quotes2","Quotes3","Quotes4","Quotes5","Quotes6","AvgQuoteAmt1","AvgQuoteAmt2","AvgQuoteAmt3","AvgQuoteAmt4","AvgQuoteAmt5","AvgQuoteAmt6",
               "AvgTIV1","AvgTIV2","AvgTIV3","AvgTIV4","AvgTIV5","AvgTIV6","Submissions1","Submissions2","Submissions3","Submissions4","Submissions5","Submissions6")

data$brokerid <- factor(data$brokerid)
save(data, file="brokerdata.rda")

#---------------------------------------------------------------------------------------------------------------
#Predictions for 2018 my training model for 2017 data

load('brokerdata.rda')
brokerdata<-data
summary(data)

#---------------------------------------------------------------------------------------------------------------
#impute missing values
for(i in 3:ncol(data)){
  data[is.na(data[,i]), i] <- 0.01
}

#----------------------------------------------------------------------------------------------------------------
#calculate the key metrices

traindataset=data
testdataset=data

#calculate the ratios for years 2014,2015 and 2016
traindataset$QuoteRatio1=(traindataset$Quotes2)/(traindataset$Submissions2)
traindataset$QuoteRatio2=(traindataset$Quotes3)/(traindataset$Submissions3)
traindataset$QuoteRatio3=(traindataset$Quotes4)/(traindataset$Submissions4)

traindataset$HitRatio1=(traindataset$policycount2)/(traindataset$Quotes2)
traindataset$HitRatio2=(traindataset$policycount3)/(traindataset$Quotes3)
traindataset$HitRatio3=(traindataset$policycount4)/(traindataset$Quotes4)

traindataset$SuccessRatio1=(traindataset$policycount2)/(traindataset$Submissions2)
traindataset$SuccessRatio2=(traindataset$policycount3)/(traindataset$Submissions3)
traindataset$SuccessRatio3=(traindataset$policycount4)/(traindataset$Submissions4)

#convert GWP for each year to categorical values indicating increase or decrease wrt to previous year
traindataset$year1<-factor(ifelse(traindataset$GWP2-traindataset$GWP1>=0,"increase","decrease"),levels=c("decrease","increase"))
traindataset$year2<-factor(ifelse(traindataset$GWP3-traindataset$GWP2>=0,"increase","decrease"),levels=c("decrease","increase"))
traindataset$year3<-factor(ifelse(traindataset$GWP4-traindataset$GWP3>=0,"increase","decrease"),levels=c("decrease","increase"))
traindataset$year4<-factor(ifelse(traindataset$GWP5-traindataset$GWP4>=0,"increase","decrease"),levels=c("decrease","increase"))

#subset data with relevant variables
library(dplyr)
dataTrain <- traindataset %>%
  dplyr::select(c(year4,year1,year2,year3,QuoteRatio1,QuoteRatio2,QuoteRatio3,
                  HitRatio1,HitRatio2,HitRatio3,SuccessRatio1,SuccessRatio2,SuccessRatio3,
                  AvgTIV1,AvgTIV2,AvgTIV3))


#calculate ratios for test dataset for years 2015,2016,2017
testdataset$QuoteRatio1=(testdataset$Quotes3)/(testdataset$Submissions3)
testdataset$QuoteRatio2=(testdataset$Quotes4)/(testdataset$Submissions4)
testdataset$QuoteRatio3=(testdataset$Quotes5)/(testdataset$Submissions5)

testdataset$HitRatio1=(testdataset$policycount3)/(testdataset$Quotes3)
testdataset$HitRatio2=(testdataset$policycount4)/(testdataset$Quotes4)
testdataset$HitRatio3=(testdataset$policycount5)/(testdataset$Quotes5)

testdataset$SuccessRatio1=(testdataset$policycount3)/(testdataset$Submissions3)
testdataset$SuccessRatio2=(testdataset$policycount4)/(testdataset$Submissions4)
testdataset$SuccessRatio3=(testdataset$policycount5)/(testdataset$Submissions5)

testdataset$year1<-factor(ifelse(testdataset$GWP3-testdataset$GWP2>=0,"increase","decrease"),levels=c("decrease","increase"))
testdataset$year2<-factor(ifelse(testdataset$GWP4-testdataset$GWP3>=0,"increase","decrease"),levels=c("decrease","increase"))
testdataset$year3<-factor(ifelse(testdataset$GWP5-testdataset$GWP4>=0,"increase","decrease"),levels=c("decrease","increase"))
testdataset$year4<-factor(ifelse(testdataset$GWP6-testdataset$GWP5>=0,"increase","decrease"),levels=c("decrease","increase"))

library(dplyr)
dataTest <- testdataset %>%
  dplyr::select(c(year4,year1,year2,year3,QuoteRatio1,QuoteRatio2,QuoteRatio3,
                  HitRatio1,HitRatio2,HitRatio3,SuccessRatio1,SuccessRatio2,SuccessRatio3,
                  AvgTIV1,AvgTIV2,AvgTIV3))


#fit logistic regression model to determine the variables that contribute to the outcome
dataLR <- glm(year4 ~ ., data=dataTrain, family=binomial("logit"))
#install.packages('MASS')

#perform stepwise backward-forward regression
library(MASS)
stepAIC(dataLR, direction='both')

#select the variables of importance
dataTrain <- traindataset %>%
  dplyr::select(c(year4,year2,year1, year3,QuoteRatio1,QuoteRatio3,
                  HitRatio1,HitRatio3,SuccessRatio1,SuccessRatio3,
                  AvgTIV2,AvgTIV3))
dataTest <- testdataset %>%
  dplyr::select(c(year4,year2,year1, year3,QuoteRatio1,QuoteRatio3,
                  HitRatio1,HitRatio3,SuccessRatio1,SuccessRatio3,
                  AvgTIV2,AvgTIV3))

#-----------------------------------------------------------------------------------------------------------------
#fit a classification tree
library(rpart)
dataRpart <- rpart(year4 ~ ., data=dataTrain)
dataPredictRpart <- predict(dataRpart, newdata=dataTest, type="class")
dataCM<-table(dataTest$year4, dataPredictRpart)
dataCM
1-sum(diag(dataCM))/sum(dataCM)

#---------------------------------------------------------------------------------------------------------------
#create a random forest
#install.packages("randomForest")
library(randomForest)  
dataRF <- randomForest(year4 ~ ., data=dataTrain)
dataPredictRF <- predict(dataRF, newdata=dataTest, type="class")
dataCM<-table(dataTest$year4, dataPredictRF)
dataCM
1-sum(diag(dataCM))/sum(dataCM)

#------------------------------------------------------------------------------------------------------------------
#fit a logistic regression
dataLR <- glm(year4 ~ ., data=dataTrain, family=binomial("logit"))
summary(dataLR)
dataprobs<-predict(dataLR, newdata=dataTest, type="response")
lr_predict<- factor(if_else(dataprobs<0.5, "decrease", "increase"),levels=c("decrease", "increase"))
dataCM<-table(dataTest$year4, lr_predict)
dataCM
1-sum(diag(dataCM))/sum(dataCM)

#------------------------------------------------------------------------------------------------------------------
#fit a neural network model
#install.packages("nnet")
#install.packages("NeuralNetTools")
library(nnet)
library(NeuralNetTools)
library(caret)

dataNN <- train(year4 ~ ., data=dataTrain,
                method="nnet",
                metric="ROC",
                trControl=trainControl(classProbs=TRUE, summaryFunction=twoClassSummary))
dataPredictNN <- predict(dataNN, newdata=dataTest, type="raw")
dataCM<-table(dataTest$year4, dataPredictNN)
dataCM
1-sum(diag(dataCM))/sum(dataCM)

#------------------------------------------------------------------------------------------------------------------
#fit a SVM model
#install.packages("e1071")
#install.packages("kernlab")
library(e1071)
library(kernlab)
library(caret)
library(dummies)
dataPreProcess <- preProcess(dataTrain)
dataTrainNumeric <- predict(dataPreProcess, dataTrain)
dataTestNumeric <- predict(dataPreProcess, dataTest)

dataSVM <- train(year4 ~ .,
                 data=dataTrainNumeric,
                 method="svmRadialWeights",
                 metric="ROC",
                 trControl=trainControl(classProbs=TRUE, summaryFunction=twoClassSummary))

dataPredictSVM <- predict(dataSVM, newdata=dataTestNumeric, type="raw")
dataCM<-table(dataTest$year4, dataPredictSVM)
dataCM
1-sum(diag(dataCM))/sum(dataCM)

#----------------------------------------------------------------------------------------------------------------
#display the ROC curves for all fitted models
install.packages('ROCR')
library(ROCR)

dataPredictRpart <- predict(dataRpart, newdata=dataTest, type="prob")
rpartPerf <- performance(prediction(dataPredictRpart[,2], dataTest$year4), "tpr", "fpr")

dataPredictRF <- predict(dataRF, newdata=dataTest, type="prob")
rfPerf <- performance(prediction(dataPredictRF[,2], dataTest$year4), "tpr", "fpr")

dataPredictSVM <- predict(dataSVM, newdata=dataTestNumeric, type="prob")
svmPerf <- performance(prediction(dataPredictSVM[,2], dataTest$year4), "tpr", "fpr")

dataPredictNN <- predict(dataNN, newdata=dataTest, type="prob")
nnPerf <- performance(prediction(dataPredictNN[,2], dataTest$year4), "tpr", "fpr")

dataPredictLR <- predict(dataLR, newdata=dataTest, type="response")
lrPerf <- performance(prediction(dataPredictLR, dataTest$year4), "tpr", "fpr")

plot(rpartPerf, col=1)
plot(rfPerf, col=2, add=TRUE)
plot(svmPerf, col=3, add=TRUE)
plot(nnPerf, col=4, add=TRUE)
plot(lrPerf, col=5, add=TRUE)

legend(0.7, 0.6, c("Class Tree", "Random Forest","SVM","Neural Network","Logistic Regression"), col=1:5, lwd=3)

#--------------------------------------------------------------------------------------------------------------------------

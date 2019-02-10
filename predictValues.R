rm(list=ls())
#---------------------------------------------------------------------------------------------------------------

#Fit the most optimal model for 2018 data and predict for 2019

load('brokerdata.rda')
brokerdata<-data
summary(data)
#---------------------------------------------------------------------------------------------------------------
#impute missing values
for(i in 3:ncol(data)){
  data[is.na(data[,i]), i] <- 0.01
}

#----------------------------------------------------------------------------------------------------------------
#create ratios

traindataset=data
#calculate the ratios for years 2015,2016,2017
traindataset$QuoteRatio1=(traindataset$Quotes3)/(traindataset$Submissions3)
traindataset$QuoteRatio2=(traindataset$Quotes4)/(traindataset$Submissions4)
traindataset$QuoteRatio3=(traindataset$Quotes5)/(traindataset$Submissions5)

traindataset$HitRatio1=(traindataset$policycount3)/(traindataset$Quotes3)
traindataset$HitRatio2=(traindataset$policycount4)/(traindataset$Quotes4)
traindataset$HitRatio3=(traindataset$policycount5)/(traindataset$Quotes5)

traindataset$SuccessRatio1=(traindataset$policycount3)/(traindataset$Submissions3)
traindataset$SuccessRatio2=(traindataset$policycount4)/(traindataset$Submissions4)
traindataset$SuccessRatio3=(traindataset$policycount5)/(traindataset$Submissions5)

#create categorical variable indicating increase or decrease of GWP from the previous year
traindataset$year1<-factor(ifelse(traindataset$GWP3-traindataset$GWP2>=0,"increase","decrease"),levels=c("decrease","increase"))
traindataset$year2<-factor(ifelse(traindataset$GWP4-traindataset$GWP3>=0,"increase","decrease"),levels=c("decrease","increase"))
traindataset$year3<-factor(ifelse(traindataset$GWP5-traindataset$GWP4>=0,"increase","decrease"),levels=c("decrease","increase"))
traindataset$year4<-factor(ifelse(traindataset$GWP6-traindataset$GWP5>=0,"increase","decrease"),levels=c("decrease","increase"))

library(dplyr)
dataTrain <- traindataset %>%
  dplyr::select(c(year4,year1,year2,year3,QuoteRatio1,QuoteRatio2,QuoteRatio3,
                  HitRatio1,HitRatio2,HitRatio3,SuccessRatio1,SuccessRatio2,SuccessRatio3,
                  AvgTIV1,AvgTIV2,AvgTIV3))


predictdataset=data

#calculate ratios for 2016, 2017, 2018
predictdataset$QuoteRatio1=(predictdataset$Quotes4)/(predictdataset$Submissions4)
predictdataset$QuoteRatio2=(predictdataset$Quotes5)/(predictdataset$Submissions5)
predictdataset$QuoteRatio3=(predictdataset$Quotes6)/(predictdataset$Submissions6)

predictdataset$HitRatio1=(predictdataset$policycount4)/(predictdataset$Quotes4)
predictdataset$HitRatio2=(predictdataset$policycount5)/(predictdataset$Quotes5)
predictdataset$HitRatio3=(predictdataset$policycount6)/(predictdataset$Quotes6)

predictdataset$SuccessRatio1=(predictdataset$policycount4)/(predictdataset$Submissions4)
predictdataset$SuccessRatio2=(predictdataset$policycount5)/(predictdataset$Submissions5)
predictdataset$SuccessRatio3=(predictdataset$policycount6)/(predictdataset$Submissions6)

predictdataset$year1<-factor(ifelse(predictdataset$GWP4-predictdataset$GWP3>=0,"increase","decrease"),levels=c("decrease","increase"))
predictdataset$year2<-factor(ifelse(predictdataset$GWP5-predictdataset$GWP4>=0,"increase","decrease"),levels=c("decrease","increase"))
predictdataset$year3<-factor(ifelse(predictdataset$GWP6-predictdataset$GWP5>=0,"increase","decrease"),levels=c("decrease","increase"))

#dataframe with the relevant variables
library(dplyr)
dataPredict <- predictdataset %>%
  dplyr::select(c(year1,year2,year3,QuoteRatio1,QuoteRatio2,QuoteRatio3,
                  HitRatio1,HitRatio2,HitRatio3,SuccessRatio1,SuccessRatio2,SuccessRatio3,
                  AvgTIV1,AvgTIV2,AvgTIV3))


#fit a glm for the trainData
dataLR <- glm(year4 ~ ., data=dataTrain, family=binomial("logit"))
#install.packages('MASS')

#perform stepwise backward-forward regression to get the important variables
library(MASS)
stepAIC(dataLR, direction='both')

#consider the important variables for fitting and prediction
dataTrain <- traindataset %>%
  dplyr::select(c(year4,year2,year1, year3,QuoteRatio3,
                  HitRatio2,HitRatio3,SuccessRatio1,SuccessRatio3,
                  AvgTIV3))
dataPredict <- predictdataset %>%
  dplyr::select(c(year2,year1, year3,QuoteRatio3,
                  HitRatio2,HitRatio3,SuccessRatio1,SuccessRatio3,
                 AvgTIV3))


#---------------------------------------------------------------------------------------------------------------
#fit a random forest
#install.packages("randomForest")
library(randomForest)  

dataRF <- randomForest(year4 ~ ., data=dataTrain)
dataprobs<-predict(dataRF, newdata=dataPredict, type="prob")
dataprobs
write.csv(dataprobs,"output.csv")

#------------------------------------------------------------------------------------------------------------------
#fit a logistic regression model
dataLR <- glm(year4 ~ ., data=dataTrain, family=binomial("logit"))
summary(dataLR)
dataprobs<-predict(dataLR, newdata=dataPredict, type="response")
as.matrix(dataprobs)

#------------------------------------------------------------------------------------------------------------------

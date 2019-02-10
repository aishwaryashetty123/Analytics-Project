
install.packages("xlsx")
library(xlsx)
data <- read.xlsx("Alchemy Broker Data.xlsx", 1)

#predictiondata<-data[ ,c(1:2,9:14)]

names(data)<-c("brokerid","brokername","policycount1","policycount2","policycount3","policycount4","policycount5","policycount6","GWP1","GWP2","GWP3","GWP4","GWP5","GWP6",
               "Quotes1","Quotes2","Quotes3","Quotes4","Quotes5","Quotes6","AvgQuoteAmt1","AvgQuoteAmt2","AvgQuoteAmt3","AvgQuoteAmt4","AvgQuoteAmt5","AvgQuoteAmt6",
               "AvgTIV1","AvgTIV2","AvgTIV3","AvgTIV4","AvgTIV5","AvgTIV6","Submissions1","Submissions2","Submissions3","Submissions4","Submissions5","Submissions6")

save(data, file="brokerdata.rda")

#---------------------------------------------------------------------------------------------------------------------------
load('brokerdata.rda')

#impute missing values
for(i in 3:ncol(data)){
  data[is.na(data[,i]), i] <- 0.01
}

#calculate overall quoteratio,hitratio and successratio for 2016,2017,2018

data$QuoteRatio=(data$Quotes4+data$Quotes5+data$Quotes6)/(data$Submissions4+data$Submissions5+data$Submissions6)

data$HitRatio=(data$policycount4+data$policycount5+data$policycount6)/(data$Quotes4+data$Quotes5+data$Quotes6)

data$SuccessRatio=(data$policycount4+data$policycount5+data$policycount6)/(data$Submissions4+data$Submissions5+data$Submissions6)

library(dummies)
library(dplyr)

dataDF <- dummy.data.frame(data[,c("GWP4","GWP5","GWP6","AvgTIV4","AvgTIV5","AvgTIV6","QuoteRatio","HitRatio","SuccessRatio")])
dataDF <- scale(dataDF, center=TRUE, scale=TRUE)

#hierarchical clustering
dataDist <- dist(dataDF)
dataHclust <- hclust(dataDist)
plot(dataHclust)
dataCut <- cutree(dataHclust, k=5)

library(cluster)
clusplot(dataDF, dataCut)

#kmeans
dataKmeans <- kmeans(dataDF, centers=5)
clusplot(dataDF, dataKmeans$cluster)

#obtain PCA values
dataPCA <- prcomp(dataDF, retx=TRUE)
summary(dataPCA)
dataPCA$rotation[,1:2]

#rm(list=ls())
#---------------------------------------------------------------------------------------------------------------

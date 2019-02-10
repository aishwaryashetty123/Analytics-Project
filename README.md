# Analytics-Project
## Evaluation and prediction of broker performance at Alchemy Insurance
Alchemy insurance, a US based insurance carrier has been facing a decline in its business profits in underwriting commercial property.

An analysis has been conducted to understand the broker population by segmenting and predicting performance in terms of the key metrics associated with the broker partnerships with Alchemy. Various stages beginning from pre-processing, segmentation and prediction were carried out during the analysis. Classification techniques revealed that many brokers have low success ratio. Furthermore, random forest prediction model presented better accuracy than the other models and was used for predicting probability of increase in the Gross Written Premium for each broker for the year 2019.

## Problem Introduction
The broker performance has been a major contribution to the business profits and hence, various key metrics have been identified to evaluate the same. These include, Gross Written Premium (GWP), submissions, quotes and policies. Evaluation involves the analysis of
- Broker segmentation over a three-year period wherein the brokers are grouped based on the characteristics of the metrics.
- Historical broker data to predict the GWP indicating an increase or decrease from the previous year’s value.

## Pre-processing
The data given has policy counts, Gross Written Premium, quotes, average quote amount, average Total Insured Value and submissions of each broker for the years 2013 to 2018. On initial analysis, the data was found to have some missing values. This may indicate that few brokers have had their quotes declined by the underwriters. To ensure that the data is preserved despite few missing values and is used for the analysis, those values were imputed with 0.01. The reason for imputing with 0.01 is to indicate that the broker didn’t have a contribution to that particular metric during that year, while also making sure that the operational metrics ratios (quote, hit and success) aren’t undefined. After imputation, these ratios were calculated accordingly for each year.
Since it’s required to provide the probability of increase of GWP in 2019, new categorical variables indicating an increase or decrease in the GWP values between two consecutive years were created.

## Methods
### Broker Segmentation
In order to analyze the broker’s performance, they have been divided into five groups using Gross Written Premium, average Total Insured Value, quote ratio, hit ratio and success ratio of the last three years (2016-2018). The values are on different scales, hence dummy variables were created for all the variables and the values were scaled and centered. Principal component analysis (PCA) was applied on the data to understand the contribution of each variable that characterizes the broker into separate groups (Plot 1.4).

The variance explained by the first principal component is 40.3% and that by the second component is an additional 17.6% (Plot 1.5). The rotation matrix indicates that the first PC is associated with GWP5, GWP4 AND GWP6 as they have the highest loading. The second PC is associated with a trade-off between having a low success ratio, low GWP6, low GWP5 and high AvgTIV6 as the loadings for those are large and have opposite signs.

Two clustering techniques- hierarchical and KMeans were used to segment the broker (Plot 1.2 and Plot 1.3). It was observed that KMeans explains better partition as compared to hierarchical clustering. As seen in Plot 1.3, majority of the brokers are grouped at the top center of the indicating that those brokers are associated with high PC2 (low success ratio and high AvgTIV6) and medium PC1 (average GWP) values.

### Gross Written Premium prediction
The training dataset contains of data from the year 2014 to 2017. Initially, all the GWPs, operational ratios and TIVs over those years were taken into account. On applying stepwise backward-forward regression analysis, the variables of importance were indicated i.e. Year2, QuoteRatio1, QuoteRatio3, HitRatio1, HitRatio3, SuccessRatio1, SuccessRatio3, AvgTIV2, AvgTIV3 contributed significantly to the prediction.

The next step was to fit a prediction model in which 5 models were tested for accuracy given the 2017 train and 2018 test datasets. Parameters were tuned for SVM model and accuracy of the models were computed by using the confusion matrix. The models were compared by plotting ROC curves (Plot 2.1); greater the area under the curve, better is the model. The models used in the analysis are (in order of increasing misclassification rate):

- Random Forest
- Logistic Regression
- Classification Tree
- Neural Network
- Support Vector Machine (SVM)

The first two models were more optimal with accuracy of around 64% and 63%, respectively, and were taken for predicting 2019 GWP values. The same process was repeated by taking 2018 as train dataset and predicting GWP values for the year 2019.

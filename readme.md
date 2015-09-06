
### Main script is 2xgboost.R
- Ignore 1xgboost
- Preprocess the data
- Converts the TRUE-FALSE columns from character to numeric (1-0)
- Fits a multinomial GBDT (gradient boosting decision tree) - Library xgboost
- Fits a multinomial elastic net logistic regression
- Fits a multinomial neural network
- Finally blend results.
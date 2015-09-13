# Script that implements an XGBoost model. 
# The algorithm is Gradient boosting decision trees. Similar to gradient boosting machines.
# Algorithm: https://en.wikipedia.org/wiki/Gradient_boosting
# Implementation (the fastest): https://github.com/dmlc/xgboost/tree/master/R-package

rm(list = ls(all = TRUE)); gc() # this removes all the elements from the global environment
# It's a nice line to have in the start of the script, so it's reproducible.
# gc() frees memory. Really important with large datasets 

source('load_packages.R')

# install.packages(c('devtools','data.table', 'caret', 'glmnet'))
# devtools::install_github('dmlc/xgboost',subdir='R-package')

# Read data 
DT <- read.csv('data/swingData_ES_1.50_v2.csv', sep=',')
DT <- setDT(DT) # converts the data.frame to data.table

# separate the target from the dataset
target = DT[, 1, with=F]$swingRecordType
DT[, swingRecordType:=NULL] # remove the column from the training data

# Remove spaces from variable names
setnames(DT, names(DT), gsub('[[:space:]]', '', names(DT)))
# This just removes symbols from the variable names
setnames(DT, names(DT), gsub('[[:punct:]]{1,}', '_', names(DT)))
# see ?regex for more examples

# data.table allows you to loop (really really fast) over each column
# and is very memory efficient. It changes each column without having an extra copy of the data.
# This is really relevant when working with large datasets
for(j in names(DT))
  set(DT, j=j, value=ifelse(grepl('TRUE', DT[[j]]), 1, 0))

set.seed(123)
#shuffle = sample(1:nrow(DT), nrow(DT))
#DT = DT[shuffle]
#target = target[shuffle]

### Cross-validation
X_all = data.matrix(DT)

# selecting number of Rounds
target = ifelse(target == -1, 2, target) # xgboost only accepts class numbers between [0, positive numbers)
dtest <- xgb.DMatrix(X_all[1:20000, ], label=target[1:20000], missing = NA)
dtrain <- xgb.DMatrix(X_all[20001:nrow(X_all), ], label=target[20001:length(target)], missing = NA)
# dtest <- xgb.DMatrix(X_test, missing = NA)

# Set parameters for xgboost model
par <- list(objective = "multi:softmax", # multinomial 
            eval_metric = "mlogloss", # loss metric
            num_class = 3, nthread = 4, 
            eta = 0.2, #learning rate
            min_child_weight = 50, gamma = .7, # decision tree parameters
            subsample = 0.6, colsample_bytree = .6, # prevent overfitting - random forest style (column and row sampling)
            max_depth = 9 # tree maximum depth, controls overfitting. 9 is fairly conservative.
)

### Run Cross Valication ###
# to figure out when the model starts overfitting
# See cvlog.txt. Around 50 trees, the train multinomial log loss function starts 
# separating from the testing set.
# cv.nround = 200
# bst.cv = xgb.cv(param=par, data = dtrain, label = target, # No need to run this, it's just to find parameters
#                 nfold = 5, nrounds=cv.nround)

### using a train-test split ###
gdbt <- xgb.train(param=par, data=dtrain, nrounds=30)
xgb.dump(gdbt, fname='results_XGBoost/2xgboost.xgb', with.stats=TRUE)

names <- colnames(X_all)
importance_matrix <- xgb.importance(names, model = gdbt)
write.csv(importance_matrix, file='results_XGBoost/xgboost_importance_matrix.txt', row.names = FALSE)

# this saves images of feature importance, I would just look at the raw data. 
# importance_matrix.txt. Higher the Gain, more important the feature.
# If it's similar to random forest it's mean decrease in gini.

png('results_XGBoost/best_30_feature_importance.png', width = 400, height = 1000)
xgb.plot.importance(importance_matrix[1:30,])
dev.off()

png('results_XGBoost/31-60_feature_importance.png', width = 400, height = 1000)
xgb.plot.importance(importance_matrix[31:60,])
dev.off()

save(gdbt, file='results_XGBoost/2gdbt.RData') # saves the model object as an RData file

# testing predictions with new data
yhat = predict(gdbt, dtest, missing = NA)
yhat = ifelse(yhat == 2, -1, yhat)
target = ifelse(target == 2, -1, target)

# confusion matrix
cfm = table(target=target[1:20000], yhat=yhat)
#           yhat
# target      -1     0     1
#      -1    749   710     0
#       0    157 16938   146
#       1      0   631   669

# Accuracy 
sum(diag(cfm)) / sum(cfm)
# [1] 0.9178


save.image(file = 'results_XGBoost/XGBoost_image.RData')


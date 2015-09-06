rm(list = ls(all = TRUE)); gc() # this removes all the elements from the global environment
# It's a nice line to have in the start of the script, so it's reproducible.
# gc() frees memory. Really important with large datasets 

# install.packages(c('devtools','data.table', 'caret', 'glmnet'))
# devtools::install_github('dmlc/xgboost',subdir='R-package')

library(data.table)
library(caret)
library(glmnet)
library(xgboost)

# Read data 
DT <- read.csv('swingData_ES_1.50_v2.csv', sep=',')
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
cv.nround = 200
bst.cv = xgb.cv(param=par, data = dtrain, label = target, 
                nfold = 5, nrounds=cv.nround)

### using a train-test split ###
gdbt <- xgb.train(param=par, data=dtrain, nrounds=30)
xgb.dump(gdbt, fname='2xgboost.xgb', with.stats=TRUE)

names <- colnames(X_all)
importance_matrix <- xgb.importance(names, model = gdbt)
write.csv(importance_matrix, file='importance_matrix.txt', row.names = FALSE)

# this saves images of feature importance, I would just look at the raw data. 
# importance_matrix.txt. Higher the Gain, more important the feature.
# If it's similar to random forest it's mean decrease in gini. 
png('feature_importance.png', width = 400, height = 800)
xgb.plot.importance(importance_matrix[1:30,])
dev.off()

png('feature_importance2.png', width = 400, height = 800)
xgb.plot.importance(importance_matrix[31:60,])
dev.off()

# Importance_matrix has a table with the gain of each feature
# This is the "importance metric" used by the model
save(importance_matrix, file='importance_gdbt.RData')
save(gdbt, file='2gdbt.RData') # saves the model object as an RData file

# testing predictions
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


### Regularized logistic regression - LASSO
# statweb.stanford.edu/~tibs/lasso/lasso.pdf
# GLMNET R package introduction: 
# http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html


# Try diffent alpha values, tune based on cross validation results.
# cv.glmnet runs a nfold cross validation, alpha is a parameter that defines
# what type of regularization mix you are using. 
# If alpha is close to zero, it's close to ridge regression.
# If alpha is close to 1, it's close to lasso regression
# LASSO (least absolute shrinkage and selection operator) selects fewer features.
# It has the advantage that is fast to train On2 and selects the "best features".
fits <- lapply(seq(0, 1, 0.1), function(s){
  cv.glmnet(X_all[20001:30000, ], y=target[20001:30000],
            nfolds=3, type.measure = 'class', family="multinomial", alpha=s)
})
save(fits, file='elastic_net.RData')

# Here I select from the models trained previously which had the smallest 
# cross validation missclassification error. (Thats the inverse of accuracy)
cv_classification_error = lapply(fits, function(fit){
  fit$cvm[fit$lambda == fit$lambda.1se]
})

# arrange the results in a data.table
glmnet_results = data.table(cbind(seq(0, 1, 0.1), do.call(c, cv_classification_error)))
setnames(glmnet_results, names(glmnet_results), c('s', 'cv_classification_error'))

# Fit model with all data and best regularization parameter
best_s = glmnet_results[which.min(cv_classification_error)]$s # get the best s, from the previous models

# Fit the model with the best parameter with all the training data.
fit <- cv.glmnet(X_all[20001:nrow(X_all), ], y=target[20001:nrow(X_all)],
                 nfolds=10, type.measure = 'class', family="multinomial", alpha=best_s)

# Evaluate results in left out data
probs = predict(fit, newx=X_all[1:20000, ], type='response', s='lambda.1se')
probs = data.table(as.matrix(probs[, ,]))
pred_inx = apply(probs, 1, function(x) which.max(x))
preds = ifelse(pred_inx == 1, -1,
               ifelse(pred_inx == 2, 0, 1))

cfm_glmnet = table(target=target[1:20000], yhat=preds)
cfm_glmnet 
### This is the confusion matrix. 
### shows the real values (target) and predicted values (yhat)

#           yhat
# target      -1     0     1
#      -1    717   742     0
#       0    185 16906   150
#       1      0   664   636

# accuracy
sum(diag(cfm_glmnet)) # total of elements in the diagonal of the confusion matrix (correctly classified)
  / 
  sum(cfm_glmnet) # total of elements
# 0.91295

# check best features in the regression model
# this gives the coefficient values for each class, but it returns it in a weird format
# a sparse matrix. So this is not nice to see results. 
coef_glm = predict(fit, newx=X_all[1:20000, ], type='coefficients', s='lambda.1se')

# This function just makes taking a look at the coefficients easier. 
get_not_null_coef <- function(coef_glm){
  # Orders coefficients of each class by the absolute value of each coefficient
  classes = names(coef_glm)
  cf = lapply(classes, function(x){
    vars_class_low = as.matrix(coef_glm[[x]])
    vars_class_low = vars_class_low[vars_class_low[,1] != 0, ]
    vars_class_low[order(abs(vars_class_low), decreasing=TRUE)]
  })
  names(cf) <- classes
  cf
}

# coefs has the value of not-null coefficients
# ranked by absolute value.
coefs = get_not_null_coef(coef_glm)
coefs

### Add other model and blend results

# Neural network - fitted using the caret package api.
# does boostraping by default (25 resamples). Will take some time...
nnet = train(x=X_all[20001:nrow(X_all), ], y=as.factor(target[20001:nrow(X_all)]),
      method = 'nnet', metric = 'Accuracy',
      maximize = TRUE, tuneLength = 10)





rm(list = ls(all = TRUE)); gc()

library(data.table)
library(caret)
library(glmnet)
library(xgboost)

# to install 
# devtools::install_github('martinbel/handy')
library(handy) 

DT <- read.csv('swingData_ES_1.50_v2.csv', sep=',')
DT <- setDT(DT)

# exclude swingSize

target = DT[, 1, with=F]$swingRecordType
DT[, swingRecordType:=NULL]

setnames(DT, names(DT), gsub('[[:space:]]', '', names(DT)))
setnames(DT, names(DT), gsub('[[:punct:]]{1,}', '_', names(DT)))

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

### Blend with regularized logistic regression - LASSO
# statweb.stanford.edu/~tibs/lasso/lasso.pdf
# GLMNET R package introduction: 
# http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html


# create a model matrix
fits <- lapply(seq(0, 1, 0.1), function(s){
  cv.glmnet(X_all[20001:30000, ], y=target[20001:30000],
            nfolds=3, type.measure = 'class', family="multinomial", alpha=s)
})
save(fits, file='elastic_net.RData')

cv_classification_error = lapply(fits, function(fit){
  fit$cvm[fit$lambda == fit$lambda.1se]
})

glmnet_results = data.table(cbind(seq(0, 1, 0.1), do.call(c, cv_classification_error)))
setnames(glmnet_results, names(glmnet_results), c('s', 'cv_classification_error'))

# Fit model with all data and best regularization parameter
best_s = glmnet_results[which.min(cv_classification_error)]$s
fit <- cv.glmnet(X_all[20001:nrow(X_all), ], y=target[20001:nrow(X_all)],
                 nfolds=10, type.measure = 'class', family="multinomial", alpha=best_s)

# Evaluate results in left out data
probs = predict(fit, newx=X_all[1:20000, ], type='response', s='lambda.1se')
probs = data.table(as.matrix(probs[, ,]))
pred_inx = apply(probs, 1, function(x) which.max(x))
preds = ifelse(pred_inx == 1, -1,
               ifelse(pred_inx == 2, 0, 1))

cfm_glmnet = table(target=target[1:20000], yhat=preds)
#           yhat
# target      -1     0     1
#      -1    717   742     0
#       0    185 16906   150
#       1      0   664   636

# accuracy
sum(diag(cfm_glmnet)) / sum(cfm_glmnet)
# 0.91295

# check best features in the regression model
coef_glm = predict(fit, newx=X_all[1:20000, ], type='coefficients', s='lambda.1se')

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

coefs = get_not_null_coef(coef_glm)
coefs





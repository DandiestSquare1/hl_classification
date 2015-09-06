library(data.table)
library(caret)
library(glmnet)
library(xgboost)

DT <- fread('SwingHiLoData.csv')

head(DT,2)

target = DT$recordType
DT[, recordType:=NULL]

setnames(DT, names(DT), gsub('[[:space:]]', '', names(DT)))

for(j in names(DT))
  set(DT, j=j, value=ifelse(grepl('TRUE', DT[[j]]), 1, 0))

set.seed(123)
shuffle = sample(1:nrow(DT), nrow(DT))
DT = DT[shuffle]
target = target[shuffle]

### Cross-validation
X_train = data.matrix(DT)
class_tbl = table(target)
scale_pos_weight = class_tbl[[1]] / class_tbl[[2]]

# selecting number of Rounds
dtrain <- xgb.DMatrix(X_train, label=target, missing = NA)
dtest <- xgb.DMatrix(X_test, missing = NA)

# parameter selection
par <- list(booster = "gbtree", objective = "reg:linear", eta = 0.2, 
            min_child_weight = 50, gamma = .7, subsample = 0.6, colsample_bytree = .6, 
            max_depth = 12, verbose = 1, scale_pos_weight = 1, lambda = 50, alpha=.1,
            eval_metric = 'auc')

bst  <- xgb.cv(params = par, data = dtrain , nrounds = 300,
               nfold = 5, verbose=TRUE)

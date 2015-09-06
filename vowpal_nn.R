rm(list = ls(all = TRUE)); gc()

# devtools::install_github('martinbel/handy')
library(handy)
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

setnames(DT, names(DT), gsub('[[:space:]]', '', names(DT)))
setnames(DT, names(DT), gsub('[[:punct:]]{1,}', '_', names(DT)))

for(j in names(DT))
  set(DT, j=j, value=ifelse(grepl('TRUE', DT[[j]]), 1, 0))
X_all = data.matrix(DT)

# convert to vw format
data_types = handy::get_feature_type(X_all, threshold = 50)
namespaces = list(n = list(varName = data_types$num_vars, keepSpace=F),
                  c = list(varName = data_types$fact_vars, keepSpace=F))
X_all = cbind(target, X_all)

# change function for multiclass.
dt2vw(X_all[1:20000, ], 'X_test.vw', namespaces=namespaces, target='target')
dt2vw(X_all[20001:nrow(X_all),], 'X_test.vw', namespaces, target='target')

dt2vw(X_all)


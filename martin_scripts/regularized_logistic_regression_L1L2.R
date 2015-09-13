### Regularized logistic regression - LASSO
# statweb.stanford.edu/~tibs/lasso/lasso.pdf
# GLMNET R package introduction: 
# http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html

rm(list = ls(all = TRUE))
source('martin_scripts/load_packages.R')
load('results_XGBoost/XGBoost_image.RData') # gets data and models from XGBoost.R

# Try diffent alpha values, tune based on cross validation results.
# cv.glmnet runs a nfold cross validation, alpha is a parameter that defines
# what type of regularization mix you are using. 
# If alpha is close to zero, it's close to ridge regression.
# If alpha is close to 1, it's close to lasso regression
# LASSO (least absolute shrinkage and selection operator) selects fewer features.
# It has the advantage that is fast to train On2 and selects the "best features".

# Run this once - It takes a while, get a coffee
# If not you can just load the RData file with the models.
fits <- lapply(seq(0, 1, 0.1), function(s){
  cv.glmnet(X_all[20001:30000, ], y=target[20001:30000],
            nfolds=3, type.measure = 'class', family="multinomial", alpha=s)
})
save(fits, file='elastic_net.RData')

load('results_regression/elastic_net.RData')

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

save(fit, file='results_regression/best_regression.RData')
load('results_regression/best_regression.RData')

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
# total of elements in the diagonal of the confusion matrix (correctly classified)
sum(diag(cfm_glmnet)) / sum(cfm_glmnet) # total of elements
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
save(coefs, file='results_regression/feature_importance.RData')

save.image('results_regression/regression_image.RData')

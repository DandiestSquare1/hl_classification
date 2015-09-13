
# run first - If you dont have them already.
# install.packages(pkgs)

pkgs = c('data.table', 'caret', 'glmnet', 'xgboost', 'reshape2',
         'ggplot2', 'plyr')

# loads all packages
sapply(pkgs, require, character.only=TRUE)


rm(list = ls(all = TRUE)); gc()
source('martin_scripts/load_packages.R')
load('results_regression/regression_image.RData')


coef_table = list()
for(i in 1:3){
  coef_table[[i]] = data.table(cbind(class=names(coefs[i]), 
                                     feature=names(coefs[[i]]), 
                                     coef=as.vector(coefs[[i]])))
}

get_best_features = lapply(coef_table, function(x){
  threshold = 0.7
  x[, coef:=as.numeric(coef)]
  cut = quantile(abs(x$coef), probs=threshold)
  x = x[abs(coef) > cut]
  x[['feature']][-1]
})

best_features = unique(unlist(get_best_features))
data = cbind(target, DT[, best_features, with=FALSE])
mean_by_target = data[, lapply(.SD, function(x) mean(x, na.rm=TRUE)),
                       by=target, .SDcols=best_features]

### Results - Plots
mean_by_target_centered = scale(mean_by_target, center=TRUE, scale=FALSE)
mean_by_target_centered = data.frame(mean_by_target_centered)

cat('Means of the best feature by each target, centered around the mean\n')
print(mean_by_target_centered)

# Reshape the data for plotting
mdf = melt(mean_by_target_centered, id.vars='target')
p = ggplot(mdf, aes(variable, value, color=target)) +
  geom_text(aes(label=target)) +
  theme_bw() +
  labs(list(title='Regression: Means of best features by each target, centered around the mean',
            x = 'Variables', y='Mean by target as define by the labels'))

png('results_regression/mean_by_class_centered.png', width = 400, height = 1000)
print(p)
dev.off()






rm(list = ls(all = TRUE)); gc()

source('load_packages.R')

load('results_XGBoost/XGBoost_image.RData')

# quantile(importance_matrix$Gain, seq(0, 1, 0.1))

# compute the gain of the best 30% Gain - set as 0.7
threshold = quantile(importance_matrix$Gain, 0.7)[[1]] # keep the 30% top features

importance_matrix = importance_matrix[Gain >= threshold]
importance_matrix = importance_matrix[order(-Gain)]
importance_matrix = importance_matrix[, Feature:=factor(Feature, levels=Feature[order(Gain)])]

# Plot best features sorted by importance
p = ggplot(importance_matrix, aes(Gain, Feature)) +
  geom_point() +
  theme_bw() +
  labs(list(title = 'Best 30% Features, sorted by the importance metric (Gain)'))

png('results_XGBoost/Best_30_percent_feature_importance.png', width = 400, height = 1000)
print(p)
dev.off()

### Compute the mean by the class for these best 30% features
best_features = as.character(importance_matrix$Feature)

# Add target column to original dataset
data = cbind(target, DT[, best_features, with=FALSE])
mean_by_target = data[, lapply(.SD, function(x) mean(x, na.rm=TRUE)), by=target, .SDcols=best_features]

cat('Means of the best feature by each target\n')
print(mean_by_target)

mean_by_target_centered = scale(mean_by_target, center=TRUE, scale=FALSE)
mean_by_target_centered = data.frame(mean_by_target_centered)

cat('Means of the best feature by each target, centered around the mean\n')
print(mean_by_target_centered)

# Reshape the data
mdf = melt(mean_by_target_centered, id.vars='target')
p = ggplot(mdf, aes(variable, value, color=target)) +
  geom_text(aes(label=target)) +
  theme_bw() +
  labs(list(title='XGBoost: Means of best features by each target, centered around the mean',
            x = 'Variables', y='Mean by target as define by the labels'))

png('results_XGBoost/mean_by_class_centered.png', width = 400, height = 1000)
print(p)
dev.off()





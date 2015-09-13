
### Clone the repository and open the RStudio project
Just double click in: hl_classification.Rproj
This brings you to the working directory. All the paths are relative from there.
Perhaps you have to change the slash to make it work in windows. I think it was \\ for each /.

### Usage of the scripts
- Run XGBoost: 
source('martin_scripts/XGBoost.R')

- Run Regression model:
source('martin_scripts/regularized_logistic_regression_L1L2.R')

### Reports from the model
- XGBoost model feature importance plots and results
source('martin_scripts/XGBoost_report.R')

- Regression model feature importance plots and results:
source('martin_scripts/regularized_logistic_regression_L1L2_report.R')

The output of these reports are stored in results_regression for regression
and results_XGBoost for XGBoost
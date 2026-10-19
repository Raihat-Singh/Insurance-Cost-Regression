# Insurance Cost Regression Analysis (R)

Regression and predictive modelling of individual medical insurance expenses in R.

## Dataset
`data/medical_insurance.csv`: 1,338 rows, 8 columns.

| Column | Meaning |
|---|---|
| age, bmi, children | numeric predictors |
| gender, region | categorical predictors |
| discount_eligibility | yes/no; behaves like a smoker flag (treat as a proxy, not a separate factor) |
| expenses | **target** |
| premium | derived from expenses, **dropped to avoid target leakage** |

Based on the Medical Cost Personal Datasets. Check the licence on the original source before redistributing the data.

## Goals
1. Exploratory data analysis of insurance expenses.
2. Forecast expenses and identify the main cost drivers.

## Methods
Data cleaning, univariate and bivariate analysis, multiple linear regression with diagnostics (residuals, VIF), Box-Cox / log transformation, interaction terms, Random Forest and Gradient Boosting with 5-fold cross-validation (`caret`), and model comparison on a held-out test set.

## How to run
```r
source("requirements.R")                       # install packages
rmarkdown::render("insurance-cost-regression.Rmd")
```
Or open the `.Rmd` in RStudio and click **Knit**. Keep the working directory at the repo root so `data/medical_insurance.csv` resolves.

## Results

Held-out test set (20% of the data; 1,069 training rows and 268 test rows after removing one duplicate). Exact figures vary slightly with the random split.

| Model | RMSE | MAE | R² |
|---|---|---|---|
| Gradient Boosting | 4,274 | 2,508 | 0.904 |
| Random Forest | 4,316 | 2,487 | 0.901 |
| Linear (raw) | 5,957 | 4,177 | 0.822 |
| Log-linear + obese x smoker-proxy | 7,744 | 3,845 | 0.806 |
| Log-linear + BMI x smoker-proxy | 8,700 | 4,188 | 0.776 |

**Best model:** Gradient Boosting (test RMSE about 4,270, R² about 0.90). Random Forest is almost identical, and both roughly halve the error of the linear model's MAE.

**Most important drivers** (tree-model importance): discount eligibility / smoker proxy (about 69%), BMI (about 17%), age (about 12%). Children, gender and region contribute almost nothing.

## Key findings
* **The smoker proxy dominates cost.** The roughly 20% of customers with discount eligibility average about 32,050 in expenses against about 8,440 for the rest.
* **BMI matters mainly for that group.** In the log-linear model, each extra BMI point raises expected expenses by about 5.4% for the smoker-proxy group but only about 0.3% for everyone else. Obese customers in the proxy group average about 41,560, versus about 21,360 for non-obese ones in the same group.
* **Age adds roughly 3.5% to expenses per year.**
* **Log transformation fits the log scale well but hurts raw-scale error.** Box-Cox suggests a lambda close to 0 (about 0.05), yet the back-transformed log-linear models have a higher RMSE than the plain linear model, because they miss the very large claims. Tree models handle that skew and interaction without manual terms.
* **Region and gender are weak predictors** once age, BMI and the smoker proxy are known.

**Limitations:** only about 1,300 rows, no medical history or claims features, and `discount_eligibility` appears to be a renamed smoker flag, so it should be read as a proxy rather than a separate factor.

## Project structure
```
insurance-cost-regression.Rmd   full analysis
data/medical_insurance.csv
requirements.R
```

## Requirements
R packages: tidyverse, skimr, GGally, caret, randomForest, gbm, car, MASS, gridExtra, rmarkdown, knitr (installed by `requirements.R`).

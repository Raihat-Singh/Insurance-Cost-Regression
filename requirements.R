pkgs <- c("tidyverse", "skimr", "GGally", "caret", "randomForest", "gbm", "car", "MASS", "gridExtra", "rmarkdown", "knitr")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)

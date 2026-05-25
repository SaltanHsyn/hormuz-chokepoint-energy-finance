# 00_install_packages.R
# Install packages needed to reproduce the Hormuz chokepoint analysis.

required <- c(
  "tidyverse", "lubridate", "broom", "sandwich", "lmtest", "tseries", "urca", "readr"
)

missing <- required[!required %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing, dependencies = TRUE)

cat("Package check complete.\n")

# 05_unit_root_tests.R
# Purpose: produce ADF, PP, and KPSS diagnostics for transformed daily variables.
# Input: data/processed/data_clean.csv
# Output: data/results/unit_root_tests_recomputed.csv

library(tidyverse)
library(tseries)

df <- read_csv("data/processed/data_clean.csv", show_col_types = FALSE)

vars <- c("Brent_Return", "WTI_Return", "OVX_Change", "VIX_Change", "BDI_Return", "BDTI_Return",
          "FX_Return", "Stock_Return", "FX_Vol_20D", "Stock_Vol_20D")
vars <- vars[vars %in% names(df)]

safe_test <- function(x, fun) {
  x <- x[is.finite(x)]
  if (length(x) < 30) return(list(statistic = NA_real_, p.value = NA_real_))
  tryCatch(fun(x), error = function(e) list(statistic = NA_real_, p.value = NA_real_))
}

res <- map_dfr(vars, function(v) {
  x <- df[[v]]
  x <- x[is.finite(x)]
  adf <- safe_test(x, function(z) adf.test(z))
  pp <- safe_test(x, function(z) pp.test(z))
  kpss <- safe_test(x, function(z) kpss.test(z, null = "Level"))
  tibble(
    Variable = v,
    N = length(x),
    ADF_stat = as.numeric(adf$statistic),
    ADF_p = as.numeric(adf$p.value),
    PP_stat = as.numeric(pp$statistic),
    PP_p = as.numeric(pp$p.value),
    KPSS_stat = as.numeric(kpss$statistic),
    KPSS_p = as.numeric(kpss$p.value),
    Decision = ifelse(!is.na(adf$p.value) & adf$p.value < 0.05 & !is.na(kpss$p.value) & kpss$p.value > 0.05,
                      "Stationary by ADF/KPSS", "Review diagnostics")
  )
})

write_csv(res, "data/results/unit_root_tests_recomputed.csv")
cat("Unit-root diagnostics written to data/results/unit_root_tests_recomputed.csv\n")

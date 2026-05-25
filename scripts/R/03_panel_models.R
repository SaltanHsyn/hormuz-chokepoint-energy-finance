# 03_panel_models.R
# Purpose: reproduce baseline panel models with country fixed effects and HC3 robust standard errors.
# Input:  data/processed/data_clean.csv produced by 01_clean_data.R
# Output: data/results/panel_models_baseline.csv

library(tidyverse)
library(broom)
library(lmtest)
library(sandwich)

df <- read_csv("data/processed/data_clean.csv", show_col_types = FALSE) %>%
  mutate(Country = factor(Country), Date = as.Date(Date))

dep_vars <- c("Financial_Vulnerability_Z", "AbsReturn_Vulnerability_Z", "FX_Vol_20D_z", "Stock_Vol_20D_z")
base_terms <- c("CGRI_Equal_Weighted", "OVX_Change", "Brent_Return", "BDI_Return", "CGRI_x_CCI")
if ("BDTI_Return" %in% names(df)) base_terms <- c(base_terms, "BDTI_Return")

run_hc3 <- function(dep) {
  f <- as.formula(paste(dep, "~", paste(base_terms, collapse = " + "), "+ factor(Country)"))
  m <- lm(f, data = df)
  ct <- coeftest(m, vcov = vcovHC(m, type = "HC3"))
  tidy_ct <- broom::tidy(ct) %>%
    transmute(Model = "Baseline_CGRI_CCI", Dependent = dep,
              Term = term, Coef = estimate, Robust_SE_HC3 = std.error,
              t = statistic, p_value = p.value,
              N = nobs(m), R2 = summary(m)$r.squared, Adj_R2 = summary(m)$adj.r.squared)
  tidy_ct
}

out <- map_dfr(dep_vars, run_hc3)
write_csv(out, "data/results/panel_models_baseline.csv")
cat("Panel baseline results written to data/results/panel_models_baseline.csv\n")

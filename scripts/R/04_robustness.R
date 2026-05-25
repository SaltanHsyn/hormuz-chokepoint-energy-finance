# 04_robustness.R
# Purpose: run the five robustness checks requested for the article.
# Checks: OVX x CCI, BDI/BDTI x CCI, CGRI_Max x CCI, China-excluded, and consolidated coefficient output.
# Input:  data/processed/data_clean.csv
# Output: data/results/robustness_recomputed.csv

library(tidyverse)
library(broom)
library(lmtest)
library(sandwich)

df <- read_csv("data/processed/data_clean.csv", show_col_types = FALSE) %>%
  mutate(Country = factor(Country), Date = as.Date(Date))

dep_vars <- c("Financial_Vulnerability_Z", "AbsReturn_Vulnerability_Z", "FX_Vol_20D_z", "Stock_Vol_20D_z")

run_model <- function(data, dep, model_name, terms) {
  f <- as.formula(paste(dep, "~", paste(terms, collapse = " + "), "+ factor(Country)"))
  m <- lm(f, data = data)
  ct <- coeftest(m, vcov = vcovHC(m, type = "HC3"))
  broom::tidy(ct) %>%
    transmute(Model = model_name, Dependent = dep, Term = term,
              Coef = estimate, Robust_SE_HC3 = std.error,
              t = statistic, p_value = p.value,
              N = nobs(m), R2 = summary(m)$r.squared, Adj_R2 = summary(m)$adj.r.squared)
}

models <- list(
  OVX_CCI = c("CGRI_Equal_Weighted", "OVX_Change", "Brent_Return", "BDI_Return", "OVX_x_CCI"),
  BDI_CCI = c("CGRI_Equal_Weighted", "OVX_Change", "Brent_Return", "BDI_Return", "BDI_x_CCI"),
  BDTI_CCI = c("CGRI_Equal_Weighted", "OVX_Change", "Brent_Return", "BDTI_Return", "BDTI_x_CCI"),
  CGRI_Max_CCI = c("CGRI_Max_Component", "OVX_Change", "Brent_Return", "BDI_Return", "CGRI_Max_x_CCI"),
  China_Excluded = c("CGRI_Equal_Weighted", "OVX_Change", "Brent_Return", "BDI_Return", "CGRI_x_CCI")
)

results <- list()
for (dep in dep_vars) {
  for (mn in names(models)) {
    use_df <- df
    if (mn == "China_Excluded") use_df <- df %>% filter(Country != "China")
    terms <- models[[mn]]
    terms <- terms[terms %in% names(use_df)]
    results[[paste(dep, mn, sep = "_")]] <- run_model(use_df, dep, mn, terms)
  }
}

out <- bind_rows(results)
write_csv(out, "data/results/robustness_recomputed.csv")
cat("Robustness results written to data/results/robustness_recomputed.csv\n")

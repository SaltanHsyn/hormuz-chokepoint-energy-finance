# 01_clean_data.R
# Purpose: clean and prepare the panel data used in the Hormuz chokepoint article.
# Input:  data/processed/data.csv
# Output: data/processed/data_clean.csv

library(tidyverse)
library(lubridate)

infile <- "data/processed/data.csv"
outfile <- "data/processed/data_clean.csv"

df <- read_csv(infile, show_col_types = FALSE) %>%
  mutate(
    Date = as.Date(Date),
    Year = as.integer(Year),
    Country = as.factor(Country),
    ISO3 = as.factor(ISO3)
  ) %>%
  arrange(Country, Date)

# Recreate key interaction terms to make the workflow auditable.
df <- df %>%
  mutate(
    CGRI_x_CCI = CGRI_Equal_Weighted * CCI_Baseline_Recomputed,
    OVX_x_CCI = OVX_Change * CCI_Baseline_Recomputed,
    BDI_x_CCI = BDI_Return * CCI_Baseline_Recomputed,
    BDTI_x_CCI = BDTI_Return * CCI_Baseline_Recomputed,
    CGRI_Max_x_CCI = CGRI_Max_Component * CCI_Baseline_Recomputed,
    CGRI_x_EnergyImport = CGRI_Equal_Weighted * EnergyImport_Norm,
    OVX_x_EnergyImport = OVX_Change * EnergyImport_Norm
  )

write_csv(df, outfile)
cat("Cleaned data written to", outfile, "\n")
cat("Rows:", nrow(df), " Columns:", ncol(df), "\n")
cat("Countries:", paste(levels(df$Country), collapse = ", "), "\n")

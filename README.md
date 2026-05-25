# Replication package: Chokepoint Risk, Oil-Market Uncertainty, and Financial Vulnerability

This package contains the raw/processed data and analysis scripts for the Energy Economics–ready version of the Hormuz chokepoint article.

## Folder structure

```text
data/raw/          Source CSV extracts from the project workbooks
data/processed/    Main analysis panel (`data.csv`) and data dictionary
data/results/      Event-study, panel, robustness and diagnostic result tables
scripts/R/         Reproducible R scripts matching the journal checklist
scripts/python/    Convenience runner for executing the R workflow
docs/              Original workbooks and the current manuscript file for provenance
```

## Main analysis file

The central replication data file is:

```text
data/processed/data.csv
```

It contains the country-day panel used for the final robustness models. The core panel includes five countries: Türkiye, Israel, India, Japan, and China. It includes CGRI, OVX, BDI/BDTI, CCI, financial vulnerability measures, and all interaction terms used in the final robustness checks.

## Scripts

Run the scripts in this order:

1. `scripts/R/01_clean_data.R` — cleans `data.csv` and recreates key interaction terms.
2. `scripts/R/02_event_study.R` — recomputes event-window baseline-adjusted responses.
3. `scripts/R/03_panel_models.R` — estimates baseline country fixed-effect panel models with HC3 robust standard errors.
4. `scripts/R/04_robustness.R` — estimates OVX x CCI, BDI/BDTI x CCI, CGRI_Max x CCI, and China-excluded robustness checks.
5. `scripts/R/05_unit_root_tests.R` — reports ADF, PP, and KPSS diagnostics for transformed variables.

A convenience Python runner is also included:

```bash
python scripts/python/run_all_analysis.py
```

## Required R packages

Run once:

```bash
Rscript scripts/R/00_install_packages.R
```

Core packages: `tidyverse`, `lubridate`, `broom`, `sandwich`, `lmtest`, `tseries`, `urca`, `readr`.

## Event-study normal period

The event-study script uses a pre-event normal/baseline period from event date -30 to event date -6. Event windows are [-1,+1], [-3,+3], and [-5,+5].

## Model convention

The panel scripts use country fixed effects via `factor(Country)` and HC3 robust standard errors. The manuscript interprets these models as screening-level structural moderation evidence rather than definitive causal identification.

## Included CSV exports

| source_workbook                                   | sheet                       | csv_path                                     |   rows |   columns |
|:--------------------------------------------------|:----------------------------|:---------------------------------------------|-------:|----------:|
| Hormuz_Core_Data_v24_Analysis_Prep(1).xlsx        | Daily_Market_Data           | data/raw/daily_market_data.csv               |   1649 |        56 |
| Hormuz_Core_Data_v24_Analysis_Prep(1).xlsx        | CGRI_Daily_Calendar         | data/raw/cgri_daily_calendar.csv             |   1964 |        14 |
| Hormuz_Core_Data_v24_Analysis_Prep(1).xlsx        | Event_Calendar_v1           | data/raw/event_calendar_v1.csv               |     21 |        18 |
| Hormuz_Core_Data_v24_Analysis_Prep(1).xlsx        | Applied_Window_Audit        | data/raw/applied_window_audit.csv            |    224 |        13 |
| Hormuz_Core_Data_v24_Analysis_Prep(1).xlsx        | Source_Log                  | data/raw/source_log.csv                      |     20 |         9 |
| Hormuz_Core_Data_v24_Analysis_Prep(1).xlsx        | CCI_Country_Year            | data/raw/cci_country_year.csv                |     93 |        24 |
| Hormuz_Energy_Corridors_Core_Data_v6_BDTI(1).xlsx | Daily_Market_Data           | data/raw/daily_market_data_with_bdti.csv     |   1970 |        41 |
| Hormuz_Energy_Corridors_Core_Data_v6_BDTI(1).xlsx | Country_CCI_Panel           | data/raw/country_cci_panel.csv               |     90 |        17 |
| Hormuz_Event_Study_Results_v1(1) (1).xlsx         | Event_Study_Results         | data/results/event_study_results.csv         |    960 |        18 |
| Hormuz_Event_Study_Results_v1(1) (1).xlsx         | Event_Summary               | data/results/event_summary.csv               |     48 |        12 |
| Hormuz_Event_Study_Results_v1(1) (1).xlsx         | Hypothesis_Assessment       | data/results/hypothesis_assessment.csv       |      4 |         4 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | Panel_Dataset_Full          | data/processed/data.csv                      |   7645 |        34 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | All_Robustness_Coefficients | data/results/robustness_coefficients_all.csv |     72 |        10 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | 10A_OVX_CCI                 | data/results/table_10a_ovx_cci.csv           |     16 |        10 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | 10B_BDI_CCI                 | data/results/table_10b_bdi_cci.csv           |     16 |        10 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | 10B_BDTI_CCI                | data/results/table_10b_bdti_cci.csv          |     16 |        10 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | 10C_CGRI_Max_CCI            | data/results/table_10c_cgri_max_cci.csv      |     12 |        10 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | 10D_China_Excluded          | data/results/table_10d_china_excluded.csv    |     12 |        10 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | Appendix_C_ADF_PP_KPSS      | data/results/appendix_c_adf_pp_kpss.csv      |     14 |        12 |
| Hormuz_Robustness_5_Checks_Results.xlsx           | Model_Notes                 | data/results/model_notes.csv                 |      9 |         2 |

## Reproducibility note

The package is designed to make the article auditable. Some original data sources may have licensing/API restrictions; therefore this package stores the project workbook extracts used in the final analysis rather than re-downloading all external sources.

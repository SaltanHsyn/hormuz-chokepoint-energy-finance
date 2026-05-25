# 02_event_study.R
# Purpose: reproduce event-study style baseline-adjusted responses.
# Inputs: data/raw/daily_market_data.csv and data/raw/cgri_daily_calendar.csv
# Output: data/results/event_study_recomputed.csv

library(tidyverse)
library(lubridate)

market <- read_csv("data/raw/daily_market_data.csv", show_col_types = FALSE) %>%
  mutate(Date = as.Date(Date))

events <- read_csv("data/raw/cgri_daily_calendar.csv", show_col_types = FALSE) %>%
  mutate(Date = as.Date(Date)) %>%
  filter(CGRI_Equal_Weighted > 0 | CGRI_Max_Component > 0) %>%
  transmute(Event_ID = row_number(), Event_Date = Date,
            CGRI_Equal_Weighted, CGRI_Max_Component, Event_Type)

vars <- c("Brent_Return", "WTI_Return", "OVX_Change", "VIX_Change", "BDI_Return")
if ("BDTI_Return" %in% names(market)) vars <- c(vars, "BDTI_Return")

windows <- tibble(label = c("[-1,+1]", "[-3,+3]", "[-5,+5]"), left = c(-1, -3, -5), right = c(1, 3, 5))

baseline_left <- -30
baseline_right <- -6

calc_one <- function(event_date, variable, left, right) {
  event_vals <- market %>% filter(Date >= event_date + days(left), Date <= event_date + days(right)) %>% pull(all_of(variable))
  base_vals <- market %>% filter(Date >= event_date + days(baseline_left), Date <= event_date + days(baseline_right)) %>% pull(all_of(variable))
  base_mean <- mean(base_vals, na.rm = TRUE)
  adj_sum <- sum(event_vals - base_mean, na.rm = TRUE)
  tibble(Variable = variable, N_Obs = sum(!is.na(event_vals)), Baseline_Mean = base_mean, Baseline_Adjusted_Sum = adj_sum)
}

res <- crossing(events, windows, Variable = vars) %>%
  group_by(Event_ID, Event_Date, Event_Type, label, left, right, Variable) %>%
  group_modify(~calc_one(.x$Event_Date[1], .x$Variable[1], .x$left[1], .x$right[1])) %>%
  ungroup() %>%
  rename(Window = label)

write_csv(res, "data/results/event_study_recomputed.csv")
cat("Event-study recomputation written to data/results/event_study_recomputed.csv\n")

# Author: Nguyen Ngoc Binh
# Purpose: Predict price of stock
# Load packages
pacman::p_load(
  xgboost,
  drake,
  tidymodels,
  modeltime,
  tidyverse,
  tidyquant,
  lubridate,
  timetk,
  modeltime.ensemble,
  httr,
  magrittr
)

# Note:
# Tickers have enough obs
source("R/ultilities_funs.R")
source("R/vndirect.R")

# Get list favor tickers
# Return object tickers
source("R/bml_stocks/R/tickers.R")

#-----------------------------------------------------------------------------
# Get data from vndirect
# Divide data to training set and test set
#-----------------------------------------------------------------------------
plan_data_preparation <- drake_plan(
  transform = FALSE,
  # Using raw_data to fit accuracy and dont need update training model
  raw_data = target({
    df = bml_vndirect_ticker_price(ticker)
    bml_data_processing(df)
  },
  transform = map(ticker = !!tickers)),
  
  # Data
  data = target(
    raw_data %>%
      # Note: prevent retrain and
      filter(date <= ymd('2021-12-31'), date > ymd('2021-12-31') - 365 * 2),
    
    transform = map(raw_data, .id = ticker)
  ),
  
  all_data = target(bind_rows(data),
                    transform = combine(data)),
  
  splits = target(
    data %>%
      time_series_split(assess = "3 months", cumulative = TRUE),
    transform = map(data, .id = ticker)
  ),
)

#-----------------------------------------------------------------------------
# Modeling plan
# 1. Arima
# 2. Arima with xgboost
# 3. exp_smoothing
# 4. prophet
#-----------------------------------------------------------------------------

plan_modelling <- drake_plan(
  interactive = FALSE,
  transform = FALSE,
  
  # # Function from ultilities_funs.R
  # modeling = target(fnc_modeling(data),
  #                   transform = map(data, .id = ticker)),
  
  # Model 1: auto_arima ----
  model_fit_arima_no_boost = target(
    arima_reg() %>%
      set_engine(engine = "auto_arima") %>%
      fit(value ~ date, data = training(splits)),
    transform = map(splits, .tag_out = bmodel, .id = ticker)
  ),
  
  
  # Model 2: arima_boost ----
  model_fit_arima_boosted = target(
    arima_boost(min_n = 2,
                learn_rate = 0.015) %>%
      set_engine(engine = "auto_arima_xgboost") %>%
      fit(
        value ~ date + as.numeric(date) + factor(month(date, label = TRUE), ordered = F),
        data = training(splits)
      ),
    transform = map(splits, .tag_out = bmodel, .id = ticker)
  ),
  
  # Model 3: ets ----
  model_fit_ets = target(
    exp_smoothing(
      seasonal_period  = 12,
      error            = "multiplicative",
      trend            = "additive",
      season           = "multiplicative"
    ) %>%
      set_engine(engine = "ets") %>%
      fit(value ~ date, data = training(splits)),
    transform = map(splits, .tag_out = bmodel, .id = ticker)
  ),
  #> frequency = 12 observations per 1 year
  
  # Model 4: prophet ----
  model_fit_prophet = target(
    prophet_reg() %>%
      set_engine(engine = "prophet", yearly.seasonality = TRUE) %>%
      fit(value ~ date, data = training(splits)),
    transform = map(splits, .tag_out = bmodel, .id = ticker)
  ),
  
  # Model 5: lm ----
  # model_fit_lm = target(
  #   linear_reg() %>%
  #     set_engine("lm") %>%
  #     fit(
  #       value ~ as.numeric(date)  + lag_open + lag_close + lag_high + lag_low + mean_20 + mean_50,
  #       data = training(splits)
  #     ),
  #   transform = map(splits, .tag_out = bmodel, .id = ticker)
  # ),
  
  # Table of models ----------------------------------------------------------
  # Note: Combine all models using results from .tag_out above
  # This is difficult tricks
  # In combine must using .by = ticker
  models_tbl = target(
    modeltime_table(bmodel),
    transform = combine(bmodel, .by = ticker, .id = ticker)
  ),
  
  # Calibartion --------------------------------------------------------------
  # In combine must using .by = ticker
  calibration_tbl = target(
    modeltime_calibrate(models_tbl, new_data = testing(splits)),
    transform = map(models_tbl, splits, .by = ticker, .id = ticker)
  ),
  
  # Forecast------------------------------------------------------------------
  # In combine must using .by = ticker
  forecast_tbl = target(
    modeltime_forecast(
      calibration_tbl,
      new_data    = testing(splits),
      # Note: using raw_data cause not update training model
      actual_data = raw_data
    ),
    transform = combine(
      calibration_tbl,
      splits,
      raw_data,
      .by = ticker,
      .id = ticker
    )
  ),
  
  # Accuracy -----------------------------------------------------------------
  accuracy_tbl = target(
    modeltime_accuracy(calibration_tbl) %>%
      table_modeltime_accuracy(.interactive = FALSE),
    transform = map(calibration_tbl, .id = ticker)
  ),
  
  # Refit --------------------------------------------------------------------
  # In combine must using .by = ticker
  # re-train on full data
  refit_tbl = target(
    modeltime_refit(calibration_tbl, data),
    transform = combine(calibration_tbl, data, .by =  ticker, .id = ticker)
  ),
  
  # Forecast next 2 month ----------------------------------------------------
  make_forecast = target(
    modeltime_forecast(
      refit_tbl,
      # Note: with lm model can't predict by horizon
      h = "2 months",
      actual_data = data,
      conf_interval = 0.9
    ),
    transform = combine(refit_tbl, data, .by = ticker, .id = ticker)
  ),
  
  # Export 1/2 month forecast
  best_accuracy_model = target(
    accuracy_tbl$`_data` %>%
      slice_min(mae) %>% 
      slice_head(n = 1)
    ,
    transform = map(accuracy_tbl, .id = ticker)
  ),
  
  two_week_fc = target(
    make_forecast %>%
      inner_join(best_accuracy_model, by = ".model_id") %>%
      filter(.index <= today() + 7, .index >= today()) %>%
      # Keep weekdays
      filter(!(weekdays(.index) %in% c("Sunday", "Saturday"))) %>% 
      # Mutate .ticker var
      mutate(.ticker = ticker) %>%
      select(
        .ticker,
        .index,
        .value,
        .low = .conf_lo,
        .high = .conf_hi,
        .model_desc = .model_desc.y
      ) %>%
      arrange(.index),
    transform = combine(
      make_forecast,
      best_accuracy_model,
      ticker,
      .by = ticker,
      .id = ticker
    )
  )
  
)


raw_plan = bind_plans(
  plan_data_preparation,
  plan_modelling
)

plan <- transform_plan(raw_plan)

# clean(destroy = TRUE)
make(plan)

# Reports =====================================================================
# Create folders
map(tickers, function(ticker) {
  if (dir.exists(paste0("vignettes/", ticker)) == F)
    dir.create(paste0("vignettes/", ticker))
})


# Create markdown files
map(tickers, bml_template_report)

#-----------------------------------------------------------------------------
source("R/vignettes_preparation.R")
# Build vignettes
# Detailed analysis for each stock
map(tickers,
    function(ticker) {
      rmarkdown::render(input = paste0("vignettes/", ticker, "/Readme.Rmd"))
    })

#-----------------------------------------------------------------------------
# Create readme
# Summary results from each stock report
bml_create_readme_file()
map(tickers, bml_readme_add_ticker)
rmarkdown::render("Readme.Rmd")

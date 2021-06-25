library(xgboost)
library(tidymodels)
library(modeltime)
library(tidyverse)
library(tidyquant)
library(lubridate)
library(timetk)
library(boostime)

# This toggles plots from plotly (interactive) to ggplot (static)
interactive <- FALSE

# Data
input_data <- read_csv("data/excel_mbb.csv") %>% 
  janitor::clean_names() %>% 
  mutate(date = ymd(dtyyyymmdd),
         value = close_fixed) %>% 
  na.omit()

data_length <- (max(input_data$date) - min(input_data$date)) %>% as.numeric()

input_data %>%
  plot_time_series(date, value, .interactive = interactive)

splits <- initial_time_split(input_data, prop = 0.9)

# Model 2: 
model_fit_arima_no_boost <- arima_reg() %>%
  set_engine(engine = "auto_arima") %>%
  fit(value ~ date, data = training(splits))


# Model 2: arima_boost ----
model_fit_arima_boosted <- arima_boost(
  min_n = 2,
  learn_rate = 0.015
) %>%
  set_engine(engine = "auto_arima_xgboost") %>%
  fit(value ~ date + as.numeric(date) + factor(month(date, label = TRUE), ordered = F),
      data = training(splits))
#> frequency = 12 observations per 1 year


# Model 3: ets ----
model_fit_ets <- exp_smoothing() %>%
  set_engine(engine = "ets") %>%
  fit(value ~ date, data = training(splits))
#> frequency = 12 observations per 1 year

# Model 4: prophet ----
model_fit_prophet <- prophet_reg() %>%
  set_engine(engine = "prophet") %>%
  fit(value ~ date, data = training(splits))
#> Disabling weekly seasonality. Run prophet with weekly.seasonality=TRUE to override this.
#> Disabling daily seasonality. Run prophet with daily.seasonality=TRUE to override this.

# Model 5: lm ----
model_fit_lm <- linear_reg() %>%
  set_engine("lm") %>%
  fit(value ~ as.numeric(date) + factor(month(date, label = TRUE), ordered = FALSE),
      data = training(splits))

# Model 6: earth ----
model_spec_mars <- mars(mode = "regression") %>%
  set_engine("earth") 

recipe_spec <- recipe(value ~ date, data = training(splits)) %>%
  step_date(date, features = "month", ordinal = FALSE) %>%
  step_mutate(date_num = as.numeric(date)) %>%
  step_normalize(date_num) %>%
  step_rm(date)

wflw_fit_mars <- workflow() %>%
  add_recipe(recipe_spec) %>%
  add_model(model_spec_mars) %>%
  fit(training(splits))

# Model 7:auto_arima_catboost

model_arima_catboost <- boost_arima() %>%
  set_engine("auto_arima_catboost", verbose = 0) %>%
  fit(value ~ date + month(date), data = training(splits))
model_arima_catboost
# ----------------------------------------------------------------------------
models_tbl <- modeltime_table(
  model_fit_arima_no_boost,
  model_fit_arima_boosted,
  model_fit_ets,
  model_fit_prophet,
  model_fit_lm,
  wflw_fit_mars
)

models_tbl

#-----------------------------------------------------------------------------
calibration_tbl <- models_tbl %>%
  modeltime_calibrate(new_data = testing(splits))

calibration_tbl

#-----------------------------------------------------------------------------
calibration_tbl %>%
  modeltime_forecast(
    new_data    = testing(splits),
    actual_data = input_data
  ) %>%
  plot_modeltime_forecast(
    .legend_max_width = 25, # For mobile screens
    .interactive      = interactive
  )

#-----------------------------------------------------------------------------
calibration_tbl %>%
  modeltime_accuracy() %>%
  table_modeltime_accuracy(
    .interactive = interactive
  )

#-----------------------------------------------------------------------------
refit_tbl <- calibration_tbl %>%
  modeltime_refit(data = input_data)

fc <- refit_tbl %>%
  modeltime_forecast(h = "10 years", actual_data = input_data, conf_interval = 0.2)

fc %>% 
  plot_modeltime_forecast(
    .legend_max_width = 25, # For mobile screens
    .interactive      = interactive
  )

fc$.model_desc %>% table() 

fc %>% 
  filter(.model_desc =="EARTH" ) %>% 
  filter(.index <= ymd(20210624), .index >= ymd(20210618)) %>% 
  arrange(desc(.index)) 


fc %>% 
  filter(.model_desc == "PROPHET") %>% 
  filter(.index <= ymd(20210624), .index >= ymd(20210618)) %>% 
  arrange(desc(.index)) 

fc %>% 
  filter(.model_desc == "UPDATE: ARIMA(1,1,1) W/ XGBOOST ERRORS") %>% 
  filter(.index <= ymd(20210624), .index >= ymd(20210618)) %>% 
  arrange(desc(.index)) 

#=============================================================================
# Tunning
library(timetk)
library(modeltime.ensemble)
# Step 1: Make resample predictions for submodels

resamples_tscv <- input_data %>%
  time_series_cv(assess  = "2 years",
                 initial = "5 years",
                 skip    = "2 years",
                 slice_limit = 1)

resamples_tscv %>% tk_time_series_cv_plan()

resamples_tscv %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)

submodel_predictions <- calibration_tbl %>%
  modeltime_fit_resamples(resamples = resamples_tscv, 
                          control = control_resamples(verbose = TRUE))

submodel_predictions$.resample_results[[1]]$.predictions
submodel_predictions$.resample_results[[1]]

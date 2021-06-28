library(xgboost)
library(drake)
library(tidymodels)
library(modeltime)
library(tidyverse)
library(tidyquant)
library(lubridate)
library(timetk)
library(modeltime.ensemble)



# library(boostime)

# This toggles plots from plotly (interactive) to ggplot (static)


my_plan <- drake_plan(
  
  interactive = FALSE,
  
  # Data
  input_data = read_csv("data/excel_acb.csv") %>%
    janitor::clean_names() %>%
    mutate(date = ymd(dtyyyymmdd),
           value = close_fixed) %>%
    na.omit(),
  
  data_length = (max(input_data$date) - min(input_data$date)) %>% as.numeric(),
  
  # Chia thanh tap train va test
  splits = input_data %>%
    time_series_split(assess = "3 months", cumulative = TRUE),
  
  # Model
  # Model 1:
  model_fit_arima_no_boost = arima_reg() %>%
    set_engine(engine = "auto_arima") %>%
    fit(value ~ date, data = training(splits)),
  
  
  # Model 2: arima_boost ----
  model_fit_arima_boosted = arima_boost(min_n = 2,
                                        learn_rate = 0.015) %>%
    set_engine(engine = "auto_arima_xgboost") %>%
    fit(
      value ~ date + as.numeric(date) + factor(month(date, label = TRUE), ordered = F),
      data = training(splits)
    ),
  #> frequency = 12 observations per 1 year
  
  
  # Model 3: ets ----
  model_fit_ets = exp_smoothing() %>%
    set_engine(engine = "ets") %>%
    fit(value ~ date, data = training(splits)),
  #> frequency = 12 observations per 1 year
  
  # Model 4: prophet ----
  model_fit_prophet = prophet_reg() %>%
    set_engine(engine = "prophet", yearly.seasonality = TRUE) %>%
    fit(value ~ date, data = training(splits)),
  #> Disabling weekly seasonality. Run prophet with weekly.seasonality=TRUE to override this.
  #> Disabling daily seasonality. Run prophet with daily.seasonality=TRUE to override this.
  
  # Model 5: lm ----
  model_fit_lm = linear_reg() %>%
    set_engine("lm") %>%
    fit(
      value ~ as.numeric(date) + factor(month(date, label = TRUE), ordered = FALSE),
      data = training(splits)
    ),
  
  # Model 6: earth ----
  model_spec_mars = mars(mode = "regression") %>%
    set_engine("earth") ,
  
  recipe_spec = recipe(value ~ date, data = training(splits)) %>%
    step_date(date, features = "month", ordinal = FALSE) %>%
    step_mutate(date_num = as.numeric(date)) %>%
    step_normalize(date_num) %>%
    step_rm(date),
  
  wflw_fit_mars = workflows::workflow() %>%
    add_recipe(recipe_spec) %>%
    add_model(model_spec_mars) %>%
    fit(training(splits)),
  
  # Model 7: randomForest ----
  model_spec_rf = rand_forest(trees = 500, min_n = 50) %>%
    set_engine("ranger"),
  
  wflw_fit_rf = workflows::workflow() %>%
    add_model(model_spec_rf) %>%
    add_recipe(recipe_spec) %>%
    fit(training(splits)),
  
  # # Model 8: Prophet Boost
  # model_spec_prophet_boost =  prophet_boost(learn_rate = 0.1) %>%
  #   set_engine("prophet_xgboost") ,
  # 
  # wflw_fit_prophet_boost = workflows::workflow() %>%
  #   add_model(model_spec_prophet_boost) %>%
  #   add_recipe(recipe_spec) %>%
  #  # fit(training(splits)),
  #  fit(log(value) ~ date + as.numeric(date) + month(date, label = TRUE), training(splits)),
  
  # Danh sach mo hinh
  models_tbl = modeltime_table(
    model_fit_arima_no_boost,
    model_fit_arima_boosted,
    model_fit_ets,
    model_fit_prophet,
    model_fit_lm,
    wflw_fit_mars,
    wflw_fit_rf # ,wflw_fit_prophet_boost
  ),
  
  # Calibartion
  calibration_tbl = models_tbl %>%
    modeltime_calibrate(new_data = testing(splits)),
  
  # Forecast
  forecast_tbl = calibration_tbl %>%
    modeltime_forecast(new_data    = testing(splits),
                       actual_data = input_data),
  
  # Accuracy
  accuracy_tbl = calibration_tbl %>%
    modeltime_accuracy() %>%
    table_modeltime_accuracy(.interactive = FALSE),
  
  best_model = accuracy_tbl$`_data` %>% 
    filter(mae == min(mae)) %>% 
    pull(.model_desc),
  
  # Refit
  refit_tbl = calibration_tbl %>%
    modeltime_refit(data = input_data),
  
  # Forecast next 1 month
  
  fc = refit_tbl %>%
    modeltime_forecast(h = "1 months",
                       actual_data = input_data,
                       conf_interval = 0.9),
  
  one_week_fc = fc %>%
    filter(.model_desc == best_model) %>% 
    filter(.index <= today() + 7, .index >= today()) %>%
    arrange(.model_desc, .index),
  
  ## Tunning 
  resamples_tscv = input_data %>%
    time_series_cv(
      assess  = "2 years",
      initial = "5 years",
      skip    = "2 years",
      slice_limit = 1
    ),
  
  submodel_predictions = calibration_tbl %>%
    modeltime_fit_resamples(resamples = resamples_tscv,
                            control = control_resamples(verbose = TRUE))
  
)


# clean(destroy = TRUE)
make(my_plan)







# # Model 7:auto_arima_catboost
# 
# model_arima_catboost <- boost_arima() %>%
#   set_engine("auto_arima_catboost", verbose = 0) %>%
#   fit(value ~ date + month(date), data = training(splits))
# model_arima_catboost
# ----------------------------------------------------------------------------




#=============================================================================


# Step 1: Make resample predictions for submodels


# submodel_predictions$.resample_results[[1]]$.predictions
# submodel_predictions$.resample_results[[1]]

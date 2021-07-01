#' @title Get data from disk
#' @author Nguyen Ngoc Binh \email{nguyenngocbinhneu@@gmail.com}
#' @importFrom janitor clean_names
#' @importFrom readr read_csv
#' @import dplyr
#' @export fnc_get_data
#' @param ticker_name name of ticker.
#' @examples
#' fnc_get_data("acb")

fnc_get_data <- function(ticker_name) {
  df <- read_csv(paste0("data/excel_", ticker_name , ".csv")) %>%
    janitor::clean_names() %>%
    mutate(date = ymd(dtyyyymmdd),
           value = close_fixed) %>%
    arrange(date) %>%
    mutate(
      lag_open = LAG(open_fixed),
      lag_close = LAG(close_fixed),
      lag_high = LAG(high_fixed),
      lag_low = LAG(low_fixed)
    ) %>%
    na.omit() %>%
    select(date, value, lag_open, lag_close, lag_high, lag_low, ticker)
  return(df)
}


#' @title Modelling
#' @description Modelling using many timeseries models
#' @details Modelling using many timeseries models
#' @author Nguyen Ngoc Binh \email{nguyenngocbinhneu@@gmail.com}
#' @importFrom workflows workflows
#' @import timetk, modeltime, parsnip, recipes, dplyr
#' @export fnc_modeling
#' @param input_data dataframe have date variable.
#' @examples
#' fnc_modeling(df_aaa)

fnc_modeling <- function(input_data) {
  splits = input_data %>%
    time_series_split(assess = "3 months", cumulative = TRUE)
  
  # Model
  # Model 1:
  model_fit_arima_no_boost = arima_reg() %>%
    set_engine(engine = "auto_arima") %>%
    fit(value ~ date, data = training(splits))
  
  
  # Model 2: arima_boost ----
  model_fit_arima_boosted = arima_boost(min_n = 2,
                                        learn_rate = 0.015) %>%
    set_engine(engine = "auto_arima_xgboost") %>%
    fit(value ~ date + as.numeric(date) + factor(month(date, label = TRUE), ordered = F),
        data = training(splits))
  #> frequency = 12 observations per 1 year
  
  
  # Model 3: ets ----
  model_fit_ets = exp_smoothing(
    seasonal_period  = 12,
    error            = "multiplicative",
    trend            = "additive",
    season           = "multiplicative"
  ) %>%
    set_engine(engine = "ets") %>%
    fit(value ~ date, data = training(splits))
  #> frequency = 12 observations per 1 year
  
  # Model 4: prophet ----
  model_fit_prophet = prophet_reg() %>%
    set_engine(engine = "prophet", yearly.seasonality = TRUE) %>%
    fit(value ~ date, data = training(splits))
  #> Disabling weekly seasonality. Run prophet with weekly.seasonality=TRUE to override this.
  #> Disabling daily seasonality. Run prophet with daily.seasonality=TRUE to override this.
  
  # Model 5: lm ----
  # dt_train = training(splits)
  model_fit_lm = linear_reg() %>%
    set_engine("lm") %>%
    fit(value ~ as.numeric(date) + factor(month(date, label = TRUE), ordered = FALSE),
        data = training(splits))
    
    # fit_xy(
    #   x = dt_train %>% select(lag_open, lag_close, lag_high, lag_low),
    #   y = dt_train %>% pull(value)
    # )
  
  
  # Model 6: earth ----
  model_spec_mars = mars(mode = "regression") %>%
    set_engine("earth")
  
  recipe_spec = recipe(value ~ date, data = training(splits)) %>%
    step_date(date, features = "month", ordinal = FALSE) %>%
    step_mutate(date_num = as.numeric(date)) %>%
    step_normalize(date_num) %>%
    step_rm(date)
  
  wflw_fit_mars = workflows::workflow() %>%
    add_recipe(recipe_spec) %>%
    add_model(model_spec_mars) %>%
    fit(training(splits))
  
  # Model 7: randomForest ----
  model_spec_rf = rand_forest(trees = 500, min_n = 50) %>%
    set_engine("ranger")
  
  wflw_fit_rf = workflows::workflow() %>%
    add_model(model_spec_rf) %>%
    add_recipe(recipe_spec) %>%
    fit(training(splits))
  
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
  )
  
  # Calibartion
  calibration_tbl = models_tbl %>%
    modeltime_calibrate(new_data = testing(splits))
  
  # Forecast
  forecast_tbl = calibration_tbl %>%
    modeltime_forecast(new_data    = testing(splits),
                       actual_data = input_data)
  
  # Accuracy
  accuracy_tbl = calibration_tbl %>%
    modeltime_accuracy() %>%
    table_modeltime_accuracy(.interactive = FALSE)
  
  best_model = accuracy_tbl$`_data` %>%
    filter(mae == min(mae)) %>%
    pull(.model_desc)
  
  # Refit
  refit_tbl = calibration_tbl %>%
    modeltime_refit(data = input_data)
  
  # Forecast next 1 month
  
  fc = refit_tbl %>%
    modeltime_forecast(h = "2 months",
                       actual_data = input_data,
                       conf_interval = 0.9)
  
  one_week_fc = fc %>%
    filter(.model_desc == best_model) %>%
    filter(.index <= today() + 7, .index >= today()) %>%
    arrange(.model_desc, .index)
  
  return(one_week_fc)
}

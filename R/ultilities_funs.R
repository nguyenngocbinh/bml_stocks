#' @title Data processing
#' @description Format data, mutate features
#' @author Nguyen Ngoc Binh \email{nguyenngocbinhneu@@gmail.com}
#' @importFrom tidyquant LAG tq_mutate
#' @export bml_data_processing
#' @param input_data dataframe get from bml_vndirect_ticker_price function
#' @examples df <- bml_vndirect_ticker_price('VCB', 100)
#' @example bml_data_processing(df)

bml_data_processing <- function(input_data = NULL){
  
  if (is.null(input_data)) {
    stop("Don't have input data")
  }
  
  cleaned_data <- input_data %>%
    
    # format data
    mutate(date = as.Date(date)) %>%
    
    # fix name variable
    mutate(value = adClose) %>%
    # Order by date
    arrange(date) %>%
    
    # create features
    mutate(
      lag_open = LAG(adOpen),
      lag_close = LAG(adClose),
      lag_high = LAG(adHigh),
      lag_low = LAG(adLow),
      lag_vol = LAG(nmVolume)
    ) %>%
    
    na.omit() %>%
    
    select(
      date,
      value,
      lag_open,
      lag_close,
      lag_high,
      lag_low,
      ticker = code,
      adOpen,
      adClose,
      adHigh,
      adLow,
      volume = nmVolume
    ) %>%
    tq_mutate(
      # tq_mutate args
      select     = value,
      mutate_fun = rollapply,
      # rollapply args
      width      = 20,
      align      = "right",
      FUN        = mean,
      # mean args
      na.rm      = TRUE,
      # tq_mutate args
      col_rename = "mean_20"
    ) %>%
    tq_mutate(
      # tq_mutate args
      select     = value,
      mutate_fun = rollapply,
      # rollapply args
      width      = 50,
      align      = "right",
      FUN        = mean,
      # mean args
      na.rm      = TRUE,
      # tq_mutate args
      col_rename = "mean_50"
    ) %>% 
    na.omit() 
  
  cleaned_data
}


#' @title Get data from disk
#' @author Nguyen Ngoc Binh \email{nguyenngocbinhneu@@gmail.com}
#' @importFrom janitor clean_names
#' @importFrom readr read_csv
#' @import dplyr
#' @import lubridate
#' @importFrom tidyquant LAG
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
      lag_low = LAG(low_fixed),
      lag_vol = LAG(volume)
    ) %>%
    na.omit() %>%
    select(date, value, lag_open, lag_close, lag_high, lag_low, ticker, open_fixed, close_fixed, high_fixed, low_fixed, volume) %>% 
    tq_mutate(
      # tq_mutate args
      select     = value,
      mutate_fun = rollapply, 
      # rollapply args
      width      = 20,
      align      = "right",
      FUN        = mean,
      # mean args
      na.rm      = TRUE,
      # tq_mutate args
      col_rename = "mean_20"
    ) %>% 
    tq_mutate(
      # tq_mutate args
      select     = value,
      mutate_fun = rollapply, 
      # rollapply args
      width      = 50,
      align      = "right",
      FUN        = mean,
      # mean args
      na.rm      = TRUE,
      # tq_mutate args
      col_rename = "mean_50"
    )
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
    time_series_split(assess = "6 months", cumulative = TRUE)
  
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


#' @param ticker_name name of ticker.
#' @examples
#' bml_template_report("acb")
bml_template_report <-  function(ticker_name){
  
line <- paste0(

'---
output: github_document
editor_options: 
chunk_output_type: console
---
  
  
```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

```{r setup, include = FALSE}
library(xgboost)
library(drake)
library(tidymodels)
library(modeltime)
library(tidyverse)
library(tidyquant)
library(lubridate)
library(timetk)
library(modeltime.ensemble)
library(dplyr)
# R.utils::sourceDirectory("D:/R/bml_stocks/R/")
# R.utils::sourceDirectory("R/")
interactive <- FALSE
```

# Forecast ', ticker_name, ' price

### Plot
```{r}
readd(data_',ticker_name,') %>%
  plot_time_series(date, value, .interactive = interactive)
```

### Divide data to train/ test

```{r}
readd(splits_',ticker_name,') %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

### Modeltime Table

```{r}
readd(models_tbl_',ticker_name,')
```

### Calibration
```{r}
readd(calibration_tbl_',ticker_name,')
```


### Forecast (Testing Set)
```{r}

readd(forecast_tbl_',ticker_name,') %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
```

### Accuracy table
```{r}
readd(accuracy_tbl_',ticker_name,')$`_data`

```
### Next week forecast
```{r}
readd(two_week_fc_',ticker_name,')
```
'
)

write(line,
      file = paste0("vignettes/", ticker_name, "/Readme.Rmd"),
      append = FALSE)

}

bml_create_readme_file <- function(){
  title = '
---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

```{r setup, include = FALSE}
library(drake)
```

# FORECAST STOCKS PRICE
  '
write(title,
      file = "Readme.Rmd",
      append = FALSE)



}

bml_readme_add_ticker <- function(ticker_name){
  line = paste0('
### ',stringr::str_to_upper(ticker_name),'
```{r}
readd(two_week_fc_',ticker_name,') %>%  knitr::kable()
```
')
  write(line,
        file = "Readme.Rmd",
        append = TRUE)
  
}


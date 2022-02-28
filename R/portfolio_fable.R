
# Author: Nguyen Ngoc Binh
# First: 2022-02-25
# Purpose: Predict price of stock
# Limited: Not using machine learning models
# - https://robjhyndman.com/hyndsight/tscv-fable/
# - https://medium0.com/m/global-identity?redirectUrl=https%3A%2F%2Ftowardsdatascience.com%2Fmultiple-time-series-forecast-demand-pattern-classification-using-r-part-2-13e284768f4


pacman::p_load(
  drake,
  tidyverse,
  magrittr,
  hrbrthemes,
  tsibble, # Tidy Temporal Data Frames and Tools
  feasts, # Feature Extraction and Statistics for Time Series
  fable,
  fable.prophet
)

rm(list = ls())
# Note:
# Tickers have enough obs
source("R/ultilities_funs.R")
source("R/vndirect.R")

# Get list favor tickers
# Return object tickers
source("R/tickers.R")

rawdata <- c('TCB', 'LPB') %>% 
  map_dfr(bml_vndirect_ticker_price)



dt <- rawdata %>% 
  rename(value = adClose) %>% 
  as_tsibble(key = ticker_name, index = date) %>% 
  fill_gaps()

#=============================================================================
# fill NA
fnc_na_vars <- function(x) {any(is.na(x))}

na_vars <- dt %>%
  select_if(fnc_na_vars) %>% 
  names() 

dt <- dt %>%
  fill(all_of(na_vars), .direction = 'down')

#=============================================================================
# split data to cross validation
cv_dt <- dt %>% 
  stretch_tsibble(.init = 360, .step = 100) 

#=============================================================================
# model

model_single_var_table <- cv_dt %>%
  model(
    # ## Model 1: Naive ----
    # naive_mod = NAIVE(log(value + 1)),
    
    # ## Model 2: Snaive ----
    # snaive_mod = SNAIVE(log(value + 1)),
    
    ## Model 3: Drift ----
    drift_mod = RW(log(value + 1) ~ drift()),
    
    ## Model 4: SES ----
    ses_mod = ETS(log(value + 1) ~ error("A") + trend("N") + season("N"),
                  opt_crit = "mse"),
    
    ## Model 5: Holt's Linear ----
    hl_mod = ETS(log(value + 1) ~ error("A") + trend("A") + season("N"),
                 opt_crit = "mse"),
    
    ## Model 6: Damped Holt's Linear ----
    hldamp_mod = ETS(log(value + 1) ~ error("A") + trend("Ad") + season("N"),
                     opt_crit = "mse"),
    
    ## Model 7: STL decomposition with ETS ----
    stl_ets_mod = decomposition_model(
      STL(log(value + 1), ~ season(window = 7)),
      ETS(season_adjust ~ season("N")),
      SNAIVE(season_week)
      # SNAIVE(season_year)
    ),
    
    ## Model 8: ARIMA ----
    arima_mod = ARIMA(log(value + 1)),
    
    # ## Model 9: Dynamic harmonic regression ----
    # dhr_mod = ARIMA(
    #   log(value + 1) ~ PDQ(0, 0, 0) + fourier(K = 3)+ lag(basicPrice) + lag(high)
    # ),
    
    # ## Model 10: TSLM ----
    # tslm_mod = TSLM(
    #   log(value + 1) ~ lag(basicPrice) + lag(high) + lag(low) + lag(nmVolume)
    # )
    
    prophet_mod = prophet(
      log(value + 1) ~ season(period = "day", order = 7) +
        season(period = "week", order = 5) +
        season(period = "year", order = 1)
    ),
    
    nnet_mod = NNETAR(log(value + 1))
    
  ) %>%
  ## Model 11: Ensemble Model ----
mutate(ensemble_sm_mod = combination_ensemble(arima_mod, ses_mod, stl_ets_mod)) 


## Model 12 VAR
model_multiple_var_table <- cv_dt %>%
  model(var_mod = VAR(vars(value, basicPrice, high, low, nmVolume)))

#=============================================================================
# ACCURACY

# Training set accuracy
train_acc_multiple <- model_multiple_var_table %>% 
  accuracy()

train_acc_single1 <- model_single_var_table %>% 
  select(-ensemble_sm_mod) %>% # not include ensemble_sm_mod
  accuracy()

train_acc_single2 <- model_single_var_table %>% 
  select(ensemble_sm_mod) %>% 
  accuracy()
  

# TSCV accuracy
test_acc_multiple <- model_multiple_var_table  %>%
  forecast(h = "3 months") %>%
  accuracy(dt) %>% 
  filter(.response == 'value')

test_acc_single1 <- model_single_var_table %>%
  select(-ensemble_sm_mod) %>% # not include ensemble_sm_mod
  forecast(h = "3 months") %>%
  accuracy(dt)

test_acc_single2 <- model_single_var_table %>%
  select(ensemble_sm_mod) %>%
  forecast(h = "3 months") %>%
  accuracy(dt)

# merge accuracy 


#=============================================================================
# REFIT

new_dt <- new_data(cv_dt, n = 10) %>% 
  append_row()

model_single_var_table %>% 
  refit(cv_dt) -> x
 

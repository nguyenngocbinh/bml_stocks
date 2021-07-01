library(xgboost)
library(drake)
library(tidymodels)
library(modeltime)
library(tidyverse)
library(tidyquant)
library(lubridate)
library(timetk)
library(modeltime.ensemble)


# Note: 
# Tickers have enough obs
tickers <-  list.files("data") %>% stringr::str_sub(7, 9) 


my_plan <- drake_plan(
  interactive = FALSE,
  
  # Data
  # Function from ultilities_funs.R
  data = target(fnc_get_data(from),
                transform = map(from = !!tickers)),
  
  # Function from ultilities_funs.R
  modeling = target(
    fnc_modeling(data),
    transform = map(data)
  )
 
  
)

# clean(destroy = TRUE)
make(my_plan)






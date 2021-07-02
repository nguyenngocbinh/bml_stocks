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
source("R/ultilities_funs.R")
tickers <-  list.files("data") %>% stringr::str_sub(7, 9) 




my_plan <- drake_plan(
  interactive = FALSE,
  
  # Data
  # Function from ultilities_funs.R
  data = target(fnc_get_data(from),
                transform = map(from = !!tickers)),
  
  splits = target(
    data %>%
    time_series_split(assess = "3 months", cumulative = TRUE),
    transform = map(data)
  ),
  
  # Function from ultilities_funs.R
  modeling = target(
    fnc_modeling(data),
    transform = map(data)
  )
 
  
)

# clean(destroy = TRUE)
make(my_plan)

# Reports =====================================================================
# Create folders
map(tickers, function(ticker) {
  if (dir.exists(paste0("vignettes/", ticker)) == F)
    dir.create(paste0("vignettes/", ticker))
})


# Create markdown files
map(tickers, fnc_template_report)

# Build vignettes
map(tickers,
    function(ticker) {
      rmarkdown::render(input = paste0("vignettes/", ticker, "/Readme.Rmd"))
    })



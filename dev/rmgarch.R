rm(list = ls())
library(readr)

library(janitor)
library(DT)
library(formattable)
library(fGarch)
library(FinTS)
# library(kableExtra)
# library(TSA) for acf 
# library(tseries)
# library(robustbase)
# library(RcppRoll) # roll_mean
# library(zoo)
# library(TTR)
library(readxl)
#library(writexl)
library(rugarch)
library(PerformanceAnalytics)
library(tidyverse)
library(magrittr)
library(lubridate)
library(tidyquant)
library(forecast)
excel_mbb <- read_csv("data/excel_mbb.csv") %>% janitor::clean_names()
excel_acb <- read_csv("data/excel_acb.csv") %>% janitor::clean_names()
excel_tcb <- read_csv("data/excel_tcb.csv") %>% janitor::clean_names()
excel_aaa <- read_csv("data/excel_aaa.csv") %>% janitor::clean_names()

stock_name <- c("tcb", "acb", "mbb")


price_raw <- excel_tcb %>% 
  bind_rows(excel_acb) %>% 
  bind_rows(excel_mbb) %>% 
  bind_rows(excel_aaa) %>%
  mutate(date = ymd(dtyyyymmdd),
         price = close_fixed) %>% 
  na.omit()

min_date <- price_raw %>% 
  group_by(ticker) %>% 
  summarise(min(date), max(date)) %>% 
  pull(`min(date)`) %>% 
  max()

data_return <- price_raw %>% 
  filter(date >= min_date) %>% 
  group_by(ticker) %>% 
  tidyquant::tq_mutate(select = price, mutate_fun = periodReturn, period = "daily") %>% 
  ungroup() %>% 
  select(ticker, date, daily.returns)

except_date <- data_return %>% 
  group_by(date) %>% 
  count() %>% 
  filter(n != 3) %>% 
  pull(date)

rX_longer <- data_return # %>% filter(date != except_date)

rX_longer_extended <- rX_longer %>%
  group_by(ticker) %>%
  future_frame(.length_out = 3, .bind_data = TRUE) %>%
  ungroup()

rX_train  <- rX_longer_extended %>% drop_na() %>% filter(ticker %in% c("MBB", "AAA", "TCB"))
rX_future <- rX_longer_extended %>% filter(is.na(daily.returns))

# Go-Garch Engine
model_fit <- garch_multivariate_reg(type = "ugarchspec") %>%
  set_engine("gogarch_rmgarch" , gogarch_specs = list(variance.model = list(garchOrder = c(2,2)),
                                                      mean.model = list(armaOrder = c(1,1)))) %>%
  fit(daily.returns ~ date + ticker, data = rX_train)

# Prediction

predictions <- predict(model_fit, rX_future)

# Conditional Mean (vs Realized Returns):

plot(model_fit$fit$models$model_1, which = 1)


# Conditional Covariance

plot(model_fit$fit$models$model_1, which = 3)

# Conditional Correlation

plot(model_fit$fit$models$model_1, which = 4)


# EW Portfolio Plot with conditional density VaR limitis

plot(model_fit$fit$models$model_1, which = 5)




# 

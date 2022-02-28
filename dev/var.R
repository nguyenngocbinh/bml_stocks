library(dplyr)
library(lubridate)
library(vars) # Load package
library(xts)

ticker_name <- "fpt"

df <- readr::read_csv(paste0("data/excel_", ticker_name , ".csv")) %>%
  janitor::clean_names() %>%
  dplyr::mutate(date = ymd(dtyyyymmdd),
         value = close_fixed) %>%
  dplyr::arrange(date) %>% 
  mutate(lag_vol = lag(volume)) %>% 
  dplyr::select(date, open_fixed,  high_fixed,  low_fixed, close_fixed, volume, lag_vol) %>% 
  na.omit()


series <- xts(x = dplyr::select(df, open_fixed,  high_fixed,  low_fixed, close_fixed, volume), order.by = df$date)
# series <- xts(x = dplyr::select(df, close_fixed, volume), order.by = df$date)
exogen_series <- xts(x = dplyr::select(df, volume), order.by = df$date)

# var.1 <- VAR(series, 2, type = "none") # Estimate the model
var.aic <- VAR(series, type = "none", lag.max = 3, ic = "AIC")
summary(var.aic)

# Extract coefficients, standard errors etc. from the object
# produced by the VAR function
est_coefs <- coef(var.aic)

pred <- predict(var.aic, n.ahead = 8, ci = 0.95) 
pred$fcst$close_fixed

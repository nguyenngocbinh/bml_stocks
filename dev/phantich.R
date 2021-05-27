library(readr)
excel_tpb <- read_csv("data/excel_tpb.csv")

stock_name <- "tpb"

str(excel_tpb)
library(janitor)

excel_tpb <- excel_tpb %>% clean_names()

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

price_raw <- excel_tpb %>% 
  mutate(time_stamp = ymd(dtyyyymmdd),
       price = close_fixed) %>% 
  na.omit()
# Change data type
data <- xts(x = price_raw$price, order.by = price_raw$time_stamp)

############################## Input #############################
start_estimation_date <- as.Date("2014-06-01")                   #
end_estimation_date <-  start_estimation_date %m+% years(5) - 1  #
start_validation_date <- start_estimation_date %m+% years(5)     #
end_validation_date <-  start_estimation_date %m+% years(6) -1   #  
##################################################################

price_raw %>% 
  mutate(ma30 = rollmean(price, 30, align = "center", fill = NA),
         ma7 = rollmean(price, 7, align = "center", fill = NA)) %>% 
  ggplot() + 
  geom_point(aes(x = time_stamp, y = price, color = "daily"), size = 1.5, alpha = 0.5) +
  geom_line(aes(x = time_stamp, y = ma30, color = "ma30"), size = 1) +
  geom_line(aes(x = time_stamp, y = ma7, color = "ma7"), size = 1)+
  scale_color_tq()+
  #scale_color_manual(values = c("#2c3e50", "#e31a1c", "#18BC9C"))+
  scale_x_date(date_labels = "%b %Y") +
  labs(x = NULL, 
       y = "Price", 
       title = paste("Market price of stock",stock_name),
       subtitle = paste0("From ", as.yearmon(end_validation_date - years(2)), 
                         " to ", as.yearmon(end_validation_date)),
       caption = "Author: Nguyen Ngoc Binh") + 
  theme(legend.position = c(0.75, 0.95),
        legend.direction = "horizontal",
        legend.title = element_blank(),
        axis.text.x = element_text(angle = 30, hjust = 1))


b_acf <- function(dt){
  p1 <- acf(dt, type = "correlation", lag.max = 30, plot = FALSE)
  p2 <- acf(dt^2, type = "correlation", lag.max = 30, plot = FALSE)
  p3 <- pacf(dt, lag.max = 30, plot = FALSE)
  p4 <- pacf(dt^2, lag.max = 30, plot = FALSE)
  
  series_name <- names(dt)
  
  p <- data.frame(acf = p1$acf, lag = p1$lag, series_name = paste ("Acf -", series_name)) %>% 
    rbind(data.frame(acf = p2$acf, lag = p2$lag, series_name = paste ("Acf - Squared", series_name))) %>% 
    rbind(data.frame(acf = p3$acf, lag = p3$lag, series_name = paste ("Pacf -", series_name))) %>% 
    rbind(data.frame(acf = p4$acf, lag = p4$lag, series_name = paste ("Pacf - Squared", series_name)))
  
  cutoff_upper <- 2/(length(dt))^0.5
  cutoff_lower <- -2/(length(dt))^0.5
  
  p %>% filter(lag != 0) %>% 
    ggplot(aes(x = lag, y = acf, color = series_name, group = series_name))+
    geom_point(size = 1.5)+
    geom_segment(aes(xend = lag, yend = 0), size = 1)+
    geom_hline(yintercept = 0)+
    geom_line(aes(y = cutoff_upper), color = "blue", linetype = 2)+
    geom_line(aes(y = cutoff_lower), color = "blue", linetype = 2)+
    facet_wrap(~ series_name, ncol = 2)+
    expand_limits(y = c(-0.2, 0.2))+
    scale_color_tq()+
    theme_tq()+
    labs(title = paste("ACF and PACF of", series_name),
         subtitle = paste0("From ", as.yearmon(end_validation_date - years(2)), 
                           " to ", as.yearmon(end_validation_date)),
         y = "Autocorrelation",
         x = "Lags",
         caption = "Author: Nguyen Ngoc Binh")+
    theme(legend.position = "none"
    ) 
}

data_return <- Return.calculate(data, method="discrete") %>% 
  na.omit() %>%
  set_colnames("Return") %>% 
  window(start = start_estimation_date, end = end_validation_date)

b_acf(dt = data_return)

library(httr)
library(jsonlite)
library(lubridate)
library(dplyr)

rm(list = ls())
link <- "https://finfo-api.vndirect.com.vn/v4/stock_prices/"

# 
resp <- GET(link)
resp
content(resp)
str(content(resp, "parsed"))

content(resp)$args

headers(resp)

headers(resp)$date


http_type(resp)  #. This method will tell us what is the type of response fetched from GET() call to the API.




http_error(resp) #. This method just verifies if the response is error free for processing


query <- list(size = 1000)

resp <- GET(link, query = query)

http_type(resp)

list_df <- resp %>% 
  content(as = "text") %>% 
  fromJSON()


list_df$totalPages



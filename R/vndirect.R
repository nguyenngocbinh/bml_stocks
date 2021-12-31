VNDIRECT <- list(
  METHODS = c('GET', 'POST', 'PUT', 'DELETE')
)

#' Request the VNDIRECT API
#' @param ticker stock symbol
#' @param size size
#' @return data.frame
#' @importFrom httr GET content
#' @importFrom magrittr extract2 `%>%`
#' @importFrom purrr map_dfr
#' @importFrom dplyr bind_rows
#' @example bml_vndirect_ticker_price('VCB', 1000)
bml_vndirect_ticker_price <- function(ticker = NULL, size = 1000) {
  
  if (is.null(ticker)) {
    stop('symbol is not set')
  }
  
  base <- "https://finfo-api.vndirect.com.vn/v4/stock_prices/"
  
  endpoint = paste('code:', ticker)
  
  params = list(
    sort = "date",
    size = size,
    page = 1,
    q = endpoint
  )
  
  res <- GET(base, query = params)
  
  df <- content(res) %>% 
    extract2('data') %>% 
    map_dfr(bind_rows) 
  
  df
}

# formals(vndirect_query)$method <- VNDIRECT$METHODS


library(plotly)
library(quantmod)


fnc_candle_stick <- function(ticker_name, date_from = Sys.Date() - 180, date_to = Sys.Date()) {
  
  dt <- fnc_get_data(ticker_name) %>% 
    filter(date >= date_from, date <= date_to)
  # create Bollinger Bands
  bbands <- BBands(dt[,c("high_fixed","low_fixed","close_fixed")])
  
  # join and subset data
  dt <- cbind(dt, data.frame(bbands[,1:3]))
  
  # colors column for increasing and decreasing
  for (i in 1:length(dt[,1])) {
    if (dt$close_fixed[i] >= dt$open_fixed[i]) {
      dt$direction[i] = 'Increasing'
    } else {
      dt$direction[i] = 'Decreasing'
    }
  }
  
  i <- list(line = list(color = '#1dd40d'))
  d <- list(line = list(color = '#d40d0d'))
  
  # plot candlestick chart
  
  fig <- dt %>% plot_ly(x = ~date, type="candlestick",
                        open = ~open_fixed, close = ~close_fixed,
                        high = ~high_fixed, low = ~low_fixed, name =  ticker_name,
                        increasing = i, decreasing = d) 
  fig <- fig %>% add_lines(x = ~date, y = ~up , name = "B Bands",
                           line = list(color = '#ccc', width = 0.5),
                           legendgroup = "Bollinger Bands",
                           hoverinfo = "none", inherit = F) 
  fig <- fig %>% add_lines(x = ~date, y = ~dn, name = "B Bands",
                           line = list(color = '#ccc', width = 0.5),
                           legendgroup = "Bollinger Bands", inherit = F,
                           showlegend = FALSE, hoverinfo = "none") 
  fig <- fig %>% add_lines(x = ~date, y = ~mavg, name = "Mv Avg",
                           line = list(color = '#E377C2', width = 0.5),
                           hoverinfo = "none", inherit = F) 
  fig <- fig %>% layout(yaxis = list(title = "Price"))
  
  # plot volume bar chart
  fig2 <- dt 
  fig2 <- fig2 %>% plot_ly(x=~date, y=~volume, type='bar', name = "Volume",
                           color = ~direction, colors = c('#1dd40d','#d40d0d')) 
  fig2 <- fig2 %>% layout(yaxis = list(title = "Volume"))
  
  # # create rangeselector buttons
  # rs <- list(visible = TRUE, x = 0.5, y = -0.055,
  #            xanchor = 'center', yref = 'paper',
  #            font = list(size = 9),
  #            buttons = list(
  #              list(count=1,
  #                   label='RESET',
  #                   step='all'),
  #              list(count=1,
  #                   label='1 YR',
  #                   step='year',
  #                   stepmode='backward'),
  #              list(count=3,
  #                   label='3 MO',
  #                   step='month',
  #                   stepmode='backward'),
  #              list(count=1,
  #                   label='1 MO',
  #                   step='month',
  #                   stepmode='backward')
  #            ))
  
  # subplot with shared x axis
  fig <- subplot(fig, fig2, heights = c(0.7,0.2), nrows=2,
                 shareX = TRUE, titleY = TRUE)
  fig <- fig %>% layout(title = toupper(ticker_name),
                        # xaxis = list(rangeselector = rs),
                        xaxis = list(rangeslider = list(visible = F)),
                        legend = list(orientation = 'h', x = 0.5, y = 1,
                                      xanchor = 'center', yref = 'paper',
                                      font = list(size = 10),
                                      bgcolor = 'transparent'))
  
  fig
  
  
}


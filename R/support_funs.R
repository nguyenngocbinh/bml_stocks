

#' @title Plot acf, pacf
#' @description Plot acf, pacf from xts object
#' @details Plot acf, pacf from xts object
#' @author Nguyen Ngoc Binh \email{nguyenngocbinhneu@@gmail.com}
#' @importFrom stats acf pacf
#' @importFrom tidyquant theme_tq scale_color_tq
#' @import ggplot2
#' @export funs_plot_acf
#' @param xts_data xts object.
#' @examples
#' data(sample_matrix)
#' sample.xts <- as.xts(sample_matrix[,1], descr='my new xts object')
#' funs_plot_acf(sample.xts)


funs_plot_acf <- function(xts_data) {
  p1 <-
    acf(xts_data,
        type = "correlation",
        lag.max = 30,
        plot = FALSE)
  p2 <-
    acf(xts_data ^ 2,
        type = "correlation",
        lag.max = 30,
        plot = FALSE)
  p3 <- pacf(xts_data, lag.max = 30, plot = FALSE)
  p4 <- pacf(xts_data ^ 2, lag.max = 30, plot = FALSE)
  
  series_name <- names(xts_data)
  
  p <-
    data.frame(
      acf = p1$acf,
      lag = p1$lag,
      series_name = paste ("Acf -", series_name)
    ) %>%
    rbind(data.frame(
      acf = p2$acf,
      lag = p2$lag,
      series_name = paste ("Acf - Squared", series_name)
    )) %>%
    rbind(data.frame(
      acf = p3$acf,
      lag = p3$lag,
      series_name = paste ("Pacf -", series_name)
    )) %>%
    rbind(data.frame(
      acf = p4$acf,
      lag = p4$lag,
      series_name = paste ("Pacf - Squared", series_name)
    ))
  
  cutoff_upper <- 2 / (length(xts_data)) ^ 0.5
  cutoff_lower <- -2 / (length(xts_data)) ^ 0.5
  
  p %>% filter(lag != 0) %>%
    ggplot(aes(
      x = lag,
      y = acf,
      color = series_name,
      group = series_name
    )) +
    geom_point(size = 1.5) +
    geom_segment(aes(xend = lag, yend = 0), size = 1) +
    geom_hline(yintercept = 0) +
    geom_line(aes(y = cutoff_upper), color = "blue", linetype = 2) +
    geom_line(aes(y = cutoff_lower), color = "blue", linetype = 2) +
    facet_wrap( ~ series_name, ncol = 2) +
    expand_limits(y = c(-0.2, 0.2)) +
    scale_color_tq() +
    theme_tq() +
    labs(
      title = paste("ACF and PACF of", series_name),
      y = "Autocorrelation",
      x = "Lags",
      caption = "Author: Nguyen Ngoc Binh"
    ) +
    theme(legend.position = "none")
}


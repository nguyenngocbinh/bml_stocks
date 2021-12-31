
# Forecast BID price

### Plot

``` r
readd(data_BID) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_BID) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_BID)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                   
#>       <int> <list>   <chr>                         
#> 1         1 <fit[+]> ARIMA(2,1,1)(2,0,1)[5]        
#> 2         2 <fit[+]> ARIMA(0,1,0) W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                   
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_BID)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                    .type .calibration_data
#>       <int> <list>   <chr>                          <chr> <list>           
#> 1         1 <fit[+]> ARIMA(2,1,1)(2,0,1)[5]         Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(0,1,0) W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                    Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                        Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_BID) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_BID)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                    .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                          <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(2,1,1)(2,0,1)[5]         Test   2.46  7.05  6.2   7.38  2.81  0.25
#> 2         2 ARIMA(0,1,0) W/ XGBOOST ERRORS Test   2.29  6.58  5.78  6.85  2.58  0.25
#> 3         3 ETS(M,AD,M)                    Test   2.67  7.63  6.72  8.03  3.08  0.08
#> 4         4 PROPHET                        Test   4.15 11.9  10.5  12.9   4.73  0.62
```

### Next week forecast

``` r
readd(two_week_fc_BID)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc                   
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>                         
#> 1 BID     2022-01-03   37.7  33.4  41.9 ARIMA(0,1,0) W/ XGBOOST ERRORS
#> 2 BID     2022-01-04   37.7  33.4  41.9 ARIMA(0,1,0) W/ XGBOOST ERRORS
#> 3 BID     2022-01-05   37.7  33.4  41.9 ARIMA(0,1,0) W/ XGBOOST ERRORS
#> 4 BID     2022-01-06   37.7  33.4  41.9 ARIMA(0,1,0) W/ XGBOOST ERRORS
#> 5 BID     2022-01-07   37.7  33.4  41.9 ARIMA(0,1,0) W/ XGBOOST ERRORS
```

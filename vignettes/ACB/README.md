
# Forecast acb price

### Plot

``` r
readd(data_acb) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_acb) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_acb)
#> # Modeltime Table
#> # A tibble: 5 x 3
#>   .model_id .model   .model_desc                                        
#>       <int> <list>   <chr>                                              
#> 1         1 <fit[+]> ARIMA(3,1,2)(2,0,2)[5]                             
#> 2         2 <fit[+]> ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                                        
#> 4         4 <fit[+]> PROPHET                                            
#> 5         5 <fit[+]> LM
```

### Calibration

``` r
readd(calibration_tbl_acb)
#> # Modeltime Table
#> # A tibble: 5 x 5
#>   .model_id .model   .model_desc                                         .type .calibration_data 
#>       <int> <list>   <chr>                                               <chr> <list>            
#> 1         1 <fit[+]> ARIMA(3,1,2)(2,0,2)[5]                              Test  <tibble [118 x 4]>
#> 2         2 <fit[+]> ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS Test  <tibble [118 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                                         Test  <tibble [118 x 4]>
#> 4         4 <fit[+]> PROPHET                                             Test  <tibble [118 x 4]>
#> 5         5 <fit[+]> LM                                                  Test  <tibble [118 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_acb) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_acb)$`_data`
#> # A tibble: 5 x 9
#>   .model_id .model_desc                                         .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                               <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(3,1,2)(2,0,2)[5]                              Test   5.25  17.5  11.4  20.0  6.55  0.24
#> 2         2 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS Test   4.82  16.0  10.5  18.1  6.1   0.86
#> 3         3 ETS(M,AD,M)                                         Test   4.95  16.5  10.8  18.7  6.22  0.59
#> 4         4 PROPHET                                             Test  11.2   39.6  24.4  50.1 11.9   0.06
#> 5         5 LM                                                  Test  15.2   54.4  33.1  75.2 15.7   0
```

### Next week forecast

``` r
readd(two_week_fc_acb)
#> # A tibble: 16 x 6
#>    .ticker .index     .value  .low .high .model_desc                                        
#>    <chr>   <date>      <dbl> <dbl> <dbl> <chr>                                              
#>  1 acb     2021-07-03   38.6  28.5  48.6 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  2 acb     2021-07-04   38.8  28.8  48.9 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  3 acb     2021-07-05   39.0  29.0  49.1 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  4 acb     2021-07-06   39.3  29.2  49.3 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  5 acb     2021-07-07   39.5  29.4  49.5 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  6 acb     2021-07-08   39.7  29.7  49.8 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  7 acb     2021-07-09   40.0  29.9  50.0 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  8 acb     2021-07-10   40.2  30.1  50.2 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#>  9 acb     2021-07-11   40.4  30.3  50.5 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 10 acb     2021-07-12   40.6  30.6  50.7 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 11 acb     2021-07-13   40.9  30.8  50.9 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 12 acb     2021-07-14   41.1  31.0  51.2 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 13 acb     2021-07-15   41.3  31.3  51.4 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 14 acb     2021-07-16   41.6  31.5  51.6 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 15 acb     2021-07-17   41.8  31.7  51.8 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 16 acb     2021-07-18   42.0  32.0  52.1 ARIMA(3,1,3)(2,0,2)[5] WITH DRIFT W/ XGBOOST ERRORS
```

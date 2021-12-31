
# Forecast HCM price

### Plot

``` r
readd(data_HCM) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_HCM) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_HCM)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                              
#>       <int> <list>   <chr>                                    
#> 1         1 <fit[+]> ARIMA(0,1,0) WITH DRIFT                  
#> 2         2 <fit[+]> ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                              
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_HCM)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                               .type .calibration_data
#>       <int> <list>   <chr>                                     <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,1,0) WITH DRIFT                   Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                               Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                                   Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_HCM) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_HCM)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                               .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                     <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,1,0) WITH DRIFT                   Test   3.4   7.62  3.84  7.99  4.02  0.55
#> 2         2 ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS Test   3.16  7.14  3.57  7.42  3.67  0.55
#> 3         3 ETS(M,AD,M)                               Test   4.79 10.7   5.41 11.5   5.62  0.01
#> 4         4 PROPHET                                   Test   4.76 11.5   5.37 10.7   5.31  0.55
```

### Next week forecast

``` r
readd(two_week_fc_HCM)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc                              
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>                                    
#> 1 HCM     2022-01-03   46.2  40.1  52.3 ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS
#> 2 HCM     2022-01-04   46.3  40.2  52.3 ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS
#> 3 HCM     2022-01-05   46.3  40.3  52.4 ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS
#> 4 HCM     2022-01-06   46.4  40.3  52.5 ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS
#> 5 HCM     2022-01-07   46.4  40.4  52.5 ARIMA(0,1,0) WITH DRIFT W/ XGBOOST ERRORS
```

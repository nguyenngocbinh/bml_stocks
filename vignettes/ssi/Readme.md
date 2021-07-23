
# Forecast ssi price

### Plot

``` r
readd(data_ssi) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_ssi) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_ssi)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(0,2,2)(1,0,2)[5]                  
#> 2         2 <fit[+]> ARIMA(0,2,2)(1,0,2)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_ssi)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data
#>       <int> <list>   <chr>                                    <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,2,2)(1,0,2)[5]                   Test  <tibble [65 x 4]>
#> 2         2 <fit[+]> ARIMA(0,2,2)(1,0,2)[5] W/ XGBOOST ERRORS Test  <tibble [65 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [65 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [65 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_ssi) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_ssi)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,2,2)(1,0,2)[5]                   Test   6.48  14.0  6.31  15.9  8.92  0.78
#> 2         2 ARIMA(0,2,2)(1,0,2)[5] W/ XGBOOST ERRORS Test   6.18  13.4  6.02  15.0  8.61  0.78
#> 3         3 ETS(M,AD,M)                              Test  11.0   24.6 10.7   29.8 13.8   0.59
#> 4         4 PROPHET                                  Test   4.94  13.1  4.81  12.4  5.51  0.8
```

### Next week forecast

``` r
readd(two_week_fc_ssi)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 ssi     2021-07-23   48.4  39.4  57.5 PROPHET    
#> 2 ssi     2021-07-26   48.8  39.7  57.9 PROPHET    
#> 3 ssi     2021-07-27   48.8  39.7  57.9 PROPHET    
#> 4 ssi     2021-07-28   48.9  39.9  58.0 PROPHET    
#> 5 ssi     2021-07-29   49.1  40.0  58.2 PROPHET    
#> 6 ssi     2021-07-30   49.2  40.1  58.3 PROPHET
```


# Forecast tng price

### Plot

``` r
readd(data_tng) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_tng) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_tng)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(2,1,2)(0,0,1)[5]                  
#> 2         2 <fit[+]> ARIMA(2,1,2)(1,0,1)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_tng)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data
#>       <int> <list>   <chr>                                    <chr> <list>           
#> 1         1 <fit[+]> ARIMA(2,1,2)(0,0,1)[5]                   Test  <tibble [65 x 4]>
#> 2         2 <fit[+]> ARIMA(2,1,2)(1,0,1)[5] W/ XGBOOST ERRORS Test  <tibble [65 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [65 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [65 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_tng) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_tng)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(2,1,2)(0,0,1)[5]                   Test   1.53  7.12  2.62  6.86  1.87  0   
#> 2         2 ARIMA(2,1,2)(1,0,1)[5] W/ XGBOOST ERRORS Test   1.63  7.67  2.78  7.28  2.06  0   
#> 3         3 ETS(M,AD,M)                              Test   1.57  7.38  2.69  7.03  1.96  0.01
#> 4         4 PROPHET                                  Test   7.42 34.0  12.7  28.3   8.02  0
```

### Next week forecast

``` r
readd(two_week_fc_tng)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc           
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>                 
#> 1 tng     2021-07-23   23.2  20.2  26.3 ARIMA(2,1,2)(0,0,1)[5]
#> 2 tng     2021-07-26   23.2  20.2  26.3 ARIMA(2,1,2)(0,0,1)[5]
#> 3 tng     2021-07-27   23.2  20.2  26.3 ARIMA(2,1,2)(0,0,1)[5]
#> 4 tng     2021-07-28   23.2  20.2  26.3 ARIMA(2,1,2)(0,0,1)[5]
#> 5 tng     2021-07-29   23.2  20.2  26.3 ARIMA(2,1,2)(0,0,1)[5]
#> 6 tng     2021-07-30   23.2  20.2  26.3 ARIMA(2,1,2)(0,0,1)[5]
```

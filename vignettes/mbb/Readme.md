
# Forecast mbb price

### Plot

``` r
readd(data_mbb) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_mbb) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_mbb)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                   
#>       <int> <list>   <chr>                         
#> 1         1 <fit[+]> ARIMA(0,2,1)                  
#> 2         2 <fit[+]> ARIMA(0,2,1) W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                   
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_mbb)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                    .type .calibration_data
#>       <int> <list>   <chr>                          <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,2,1)                   Test  <tibble [65 x 4]>
#> 2         2 <fit[+]> ARIMA(0,2,1) W/ XGBOOST ERRORS Test  <tibble [65 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                    Test  <tibble [65 x 4]>
#> 4         4 <fit[+]> PROPHET                        Test  <tibble [65 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_mbb) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_mbb)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                    .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                          <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,2,1)                   Test   3.24 11.5   7.12 12.6   4.06  0.91
#> 2         2 ARIMA(0,2,1) W/ XGBOOST ERRORS Test   2.9  10.2   6.37 11.1   3.73  0.91
#> 3         3 ETS(M,AD,M)                    Test   4.81 17.2  10.6  19.5   5.84  0.67
#> 4         4 PROPHET                        Test   2.01  7.07  4.41  7.47  2.66  0.89
```

### Next week forecast

``` r
readd(two_week_fc_mbb)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 mbb     2021-07-23   31.3  26.9  35.7 PROPHET    
#> 2 mbb     2021-07-26   31.5  27.1  35.9 PROPHET    
#> 3 mbb     2021-07-27   31.6  27.2  36.0 PROPHET    
#> 4 mbb     2021-07-28   31.7  27.3  36.1 PROPHET    
#> 5 mbb     2021-07-29   31.8  27.4  36.2 PROPHET    
#> 6 mbb     2021-07-30   31.9  27.5  36.3 PROPHET
```

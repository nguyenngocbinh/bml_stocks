
# Forecast vcb price

### Plot

``` r
readd(data_vcb) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_vcb) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_vcb)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(1,1,0)(0,0,1)[5]                  
#> 2         2 <fit[+]> ARIMA(4,1,3)(1,0,0)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_vcb)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data
#>       <int> <list>   <chr>                                    <chr> <list>           
#> 1         1 <fit[+]> ARIMA(1,1,0)(0,0,1)[5]                   Test  <tibble [65 x 4]>
#> 2         2 <fit[+]> ARIMA(4,1,3)(1,0,0)[5] W/ XGBOOST ERRORS Test  <tibble [65 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [65 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [65 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_vcb) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_vcb)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(1,1,0)(0,0,1)[5]                   Test   6.53  6.2   4.34  6.51  8.32  0   
#> 2         2 ARIMA(4,1,3)(1,0,0)[5] W/ XGBOOST ERRORS Test   6.29  5.97  4.18  6.26  8.12  0.25
#> 3         3 ETS(M,AD,M)                              Test   6.26  5.94  4.16  6.23  8.08  0.01
#> 4         4 PROPHET                                  Test   4.84  4.85  3.21  4.71  5.58  0.48
```

### Next week forecast

``` r
readd(two_week_fc_vcb)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 vcb     2021-07-23   105.  96.1  115. PROPHET    
#> 2 vcb     2021-07-26   105.  95.7  114. PROPHET    
#> 3 vcb     2021-07-27   105.  96.0  114. PROPHET    
#> 4 vcb     2021-07-28   105.  96.2  115. PROPHET    
#> 5 vcb     2021-07-29   106.  96.7  115. PROPHET    
#> 6 vcb     2021-07-30   106.  96.5  115. PROPHET
```

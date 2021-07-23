
# Forecast sbs price

### Plot

``` r
readd(data_sbs) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_sbs) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_sbs)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                   
#>       <int> <list>   <chr>                         
#> 1         1 <fit[+]> ARIMA(0,2,1)(1,0,0)[5]        
#> 2         2 <fit[+]> ARIMA(0,2,1) W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                   
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_sbs)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                    .type .calibration_data
#>       <int> <list>   <chr>                          <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,2,1)(1,0,0)[5]         Test  <tibble [65 x 4]>
#> 2         2 <fit[+]> ARIMA(0,2,1) W/ XGBOOST ERRORS Test  <tibble [65 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                    Test  <tibble [65 x 4]>
#> 4         4 <fit[+]> PROPHET                        Test  <tibble [65 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_sbs) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_sbs)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                    .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                          <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,2,1)(1,0,0)[5]         Test   1.92  16.1  4.29  18.0  2.61  0.66
#> 2         2 ARIMA(0,2,1) W/ XGBOOST ERRORS Test   1.84  15.9  4.12  17.2  2.44  0.66
#> 3         3 ETS(M,AD,M)                    Test   3.07  25.7  6.88  31.9  4.13  0.01
#> 4         4 PROPHET                        Test   1.63  17.5  3.64  15.9  1.96  0.63
```

### Next week forecast

``` r
readd(two_week_fc_sbs)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 sbs     2021-07-23   13.6  10.3  16.8 PROPHET    
#> 2 sbs     2021-07-26   13.7  10.4  16.9 PROPHET    
#> 3 sbs     2021-07-27   13.7  10.4  16.9 PROPHET    
#> 4 sbs     2021-07-28   13.8  10.5  17.0 PROPHET    
#> 5 sbs     2021-07-29   13.8  10.6  17.0 PROPHET    
#> 6 sbs     2021-07-30   13.9  10.6  17.1 PROPHET
```


# Forecast hdg price

### Plot

``` r
readd(data_hdg) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_hdg) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_hdg)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(0,2,1)(0,0,1)[5]                  
#> 2         2 <fit[+]> ARIMA(0,2,1)(0,0,1)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_hdg)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data
#>       <int> <list>   <chr>                                    <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,2,1)(0,0,1)[5]                   Test  <tibble [65 x 4]>
#> 2         2 <fit[+]> ARIMA(0,2,1)(0,0,1)[5] W/ XGBOOST ERRORS Test  <tibble [65 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [65 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [65 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_hdg) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_hdg)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,2,1)(0,0,1)[5]                   Test   4.29 10.3   6.44  9.63  4.89  0.07
#> 2         2 ARIMA(0,2,1)(0,0,1)[5] W/ XGBOOST ERRORS Test   4.66 11.2   7    10.4   5.25  0.07
#> 3         3 ETS(M,AD,M)                              Test   1.59  3.87  2.38  3.75  2.19  0   
#> 4         4 PROPHET                                  Test  13.6  32.2  20.4  27.4  14.2   0.06
```

### Next week forecast

``` r
readd(two_week_fc_hdg)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 hdg     2021-07-23   43.5  39.9  47.1 ETS(M,AD,M)
#> 2 hdg     2021-07-26   44.0  40.4  47.6 ETS(M,AD,M)
#> 3 hdg     2021-07-27   43.9  40.3  47.5 ETS(M,AD,M)
#> 4 hdg     2021-07-28   43.8  40.1  47.4 ETS(M,AD,M)
#> 5 hdg     2021-07-29   43.5  39.8  47.1 ETS(M,AD,M)
#> 6 hdg     2021-07-30   43.6  40.0  47.2 ETS(M,AD,M)
```


# Forecast VCB price

### Plot

``` r
readd(data_VCB) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_VCB) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_VCB)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(2,1,2)(1,0,0)[5]                  
#> 2         2 <fit[+]> ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_VCB)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data
#>       <int> <list>   <chr>                                    <chr> <list>           
#> 1         1 <fit[+]> ARIMA(2,1,2)(1,0,0)[5]                   Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_VCB) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_VCB)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(2,1,2)(1,0,0)[5]                   Test   1.48  1.91  1.81  1.93  2.1   0.01
#> 2         2 ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS Test   1.45  1.89  1.77  1.9   2.03  0.01
#> 3         3 ETS(M,AD,M)                              Test   1.63  2.11  2     2.14  2.3   0.1 
#> 4         4 PROPHET                                  Test   1.9   2.46  2.32  2.49  2.54  0.28
```

### Next week forecast

``` r
readd(two_week_fc_VCB)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc                             
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>                                   
#> 1 VCB     2022-01-03   79.2  75.9  82.6 ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS
#> 2 VCB     2022-01-04   79.2  75.9  82.6 ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS
#> 3 VCB     2022-01-05   79.2  75.9  82.6 ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS
#> 4 VCB     2022-01-06   79.2  75.9  82.6 ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS
#> 5 VCB     2022-01-07   79.2  75.9  82.6 ARIMA(2,1,2)(0,0,1)[5] W/ XGBOOST ERRORS
```

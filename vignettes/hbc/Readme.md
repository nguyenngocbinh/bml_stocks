
# Forecast HBC price

### Plot

``` r
readd(data_HBC) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_HBC) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_HBC)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                   
#>       <int> <list>   <chr>                         
#> 1         1 <fit[+]> ARIMA(0,1,0)                  
#> 2         2 <fit[+]> ARIMA(0,1,0) W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                   
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_HBC)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                    .type .calibration_data
#>       <int> <list>   <chr>                          <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,1,0)                   Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(0,1,0) W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                    Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                        Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_HBC) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_HBC)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                    .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                          <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,1,0)                   Test   7     27.5  9.49  33.4  8.14 NA   
#> 2         2 ARIMA(0,1,0) W/ XGBOOST ERRORS Test   6.69  26.3  9.07  31.6  7.8   0   
#> 3         3 ETS(M,AD,M)                    Test   6.1   24.0  8.26  28.3  7.12  0.76
#> 4         4 PROPHET                        Test   9.35  37.7 12.7   48.1 10.3   0.78
```

### Next week forecast

``` r
readd(two_week_fc_HBC)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 HBC     2022-01-03   30.3  18.6  42.1 ETS(M,AD,M)
#> 2 HBC     2022-01-04   30.7  18.9  42.4 ETS(M,AD,M)
#> 3 HBC     2022-01-05   30.9  19.1  42.7 ETS(M,AD,M)
#> 4 HBC     2022-01-06   31.0  19.2  42.7 ETS(M,AD,M)
#> 5 HBC     2022-01-07   31.0  19.2  42.7 ETS(M,AD,M)
```

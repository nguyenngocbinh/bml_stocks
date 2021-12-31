
# Forecast ACB price

### Plot

``` r
readd(data_ACB) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_ACB) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_ACB)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                                        
#>       <int> <list>   <chr>                                              
#> 1         1 <fit[+]> ARIMA(0,1,0) WITH DRIFT                            
#> 2         2 <fit[+]> ARIMA(2,1,2)(0,0,1)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                                        
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_ACB)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                                         .type .calibration_data
#>       <int> <list>   <chr>                                               <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,1,0) WITH DRIFT                             Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(2,1,2)(0,0,1)[5] WITH DRIFT W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                                         Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                                             Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_ACB) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_ACB)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                                         .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                               <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,1,0) WITH DRIFT                             Test   0.93  2.84  2.8   2.78  1.13  0.22
#> 2         2 ARIMA(2,1,2)(0,0,1)[5] WITH DRIFT W/ XGBOOST ERRORS Test   1.25  3.82  3.77  3.73  1.43  0.22
#> 3         3 ETS(M,AD,M)                                         Test   1     2.99  3.01  3.05  1.2   0.02
#> 4         4 PROPHET                                             Test   1.34  4.01  4.03  4.11  1.54  0.21
```

### Next week forecast

``` r
readd(two_week_fc_ACB)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc            
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>                  
#> 1 ACB     2022-01-03   34.6  32.8  36.5 ARIMA(0,1,0) WITH DRIFT
#> 2 ACB     2022-01-04   34.7  32.8  36.5 ARIMA(0,1,0) WITH DRIFT
#> 3 ACB     2022-01-05   34.7  32.8  36.6 ARIMA(0,1,0) WITH DRIFT
#> 4 ACB     2022-01-06   34.7  32.9  36.6 ARIMA(0,1,0) WITH DRIFT
#> 5 ACB     2022-01-07   34.8  32.9  36.7 ARIMA(0,1,0) WITH DRIFT
```

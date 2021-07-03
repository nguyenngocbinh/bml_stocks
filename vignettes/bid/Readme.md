
# Forecast bid price

### Plot

``` r
readd(data_bid) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_bid) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_bid)
#> # Modeltime Table
#> # A tibble: 5 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(0,1,0)                            
#> 2         2 <fit[+]> ARIMA(0,1,0)(2,0,0)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET                                 
#> 5         5 <fit[+]> LM
```

### Calibration

``` r
readd(calibration_tbl_bid)
#> # Modeltime Table
#> # A tibble: 5 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data 
#>       <int> <list>   <chr>                                    <chr> <list>            
#> 1         1 <fit[+]> ARIMA(0,1,0)                             Test  <tibble [118 x 4]>
#> 2         2 <fit[+]> ARIMA(0,1,0)(2,0,0)[5] W/ XGBOOST ERRORS Test  <tibble [118 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [118 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [118 x 4]>
#> 5         5 <fit[+]> LM                                       Test  <tibble [118 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_bid) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_bid)$`_data`
#> # A tibble: 5 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,1,0)                             Test   3.55  8.34  4.8   7.9   4.08 NA   
#> 2         2 ARIMA(0,1,0)(2,0,0)[5] W/ XGBOOST ERRORS Test   3.94  9.24  5.31  8.71  4.5   0.19
#> 3         3 ETS(M,AD,M)                              Test   5.22 12.2   7.05 11.4   5.75  0.04
#> 4         4 PROPHET                                  Test   2.38  5.38  3.21  5.38  2.86  0.04
#> 5         5 LM                                       Test   2.38  5.33  3.22  5.4   2.95  0.19
```

### Next week forecast

``` r
readd(two_week_fc_bid)
#> # A tibble: 16 x 6
#>    .ticker .index     .value  .low .high .model_desc
#>    <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#>  1 bid     2021-07-03   43.4  38.7  48.1 PROPHET    
#>  2 bid     2021-07-04   43.4  38.7  48.1 PROPHET    
#>  3 bid     2021-07-05   41.8  37.1  46.5 PROPHET    
#>  4 bid     2021-07-06   41.8  37.1  46.5 PROPHET    
#>  5 bid     2021-07-07   41.9  37.2  46.6 PROPHET    
#>  6 bid     2021-07-08   41.9  37.2  46.6 PROPHET    
#>  7 bid     2021-07-09   41.9  37.2  46.6 PROPHET    
#>  8 bid     2021-07-10   43.4  38.7  48.1 PROPHET    
#>  9 bid     2021-07-11   43.4  38.7  48.1 PROPHET    
#> 10 bid     2021-07-12   41.9  37.2  46.6 PROPHET    
#> 11 bid     2021-07-13   42.0  37.3  46.7 PROPHET    
#> 12 bid     2021-07-14   42.0  37.3  46.8 PROPHET    
#> 13 bid     2021-07-15   42.1  37.4  46.8 PROPHET    
#> 14 bid     2021-07-16   42.2  37.5  46.9 PROPHET    
#> 15 bid     2021-07-17   43.7  39.0  48.4 PROPHET    
#> 16 bid     2021-07-18   43.7  39.0  48.4 PROPHET
```

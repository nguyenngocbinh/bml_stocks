
# Forecast SSI price

### Plot

``` r
readd(data_SSI) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_SSI) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_SSI)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                                        
#>       <int> <list>   <chr>                                              
#> 1         1 <fit[+]> ARIMA(0,1,0)(0,0,1)[5] WITH DRIFT                  
#> 2         2 <fit[+]> ARIMA(0,1,0)(1,0,0)[5] WITH DRIFT W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                                        
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_SSI)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                                         .type .calibration_data
#>       <int> <list>   <chr>                                               <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,1,0)(0,0,1)[5] WITH DRIFT                   Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(0,1,0)(1,0,0)[5] WITH DRIFT W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                                         Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                                             Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_SSI) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_SSI)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                                         .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                               <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,1,0)(0,0,1)[5] WITH DRIFT                   Test   4.34  8.69  4.48  9.13  5.29  0.69
#> 2         2 ARIMA(0,1,0)(1,0,0)[5] WITH DRIFT W/ XGBOOST ERRORS Test   4.16  8.43  4.3   8.77  5.02  0.69
#> 3         3 ETS(M,AD,M)                                         Test   5.09 10.1   5.25 10.8   6.2   0.61
#> 4         4 PROPHET                                             Test   3.99  8.99  4.12  8.5   4.6   0.69
```

### Next week forecast

``` r
readd(two_week_fc_SSI)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 SSI     2022-01-03   52.1  44.5  59.7 PROPHET    
#> 2 SSI     2022-01-04   52.1  44.5  59.7 PROPHET    
#> 3 SSI     2022-01-05   52.2  44.6  59.8 PROPHET    
#> 4 SSI     2022-01-06   52.4  44.8  60.0 PROPHET    
#> 5 SSI     2022-01-07   52.5  44.9  60.1 PROPHET
```

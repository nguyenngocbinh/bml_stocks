
# Forecast hbc price

### Plot

``` r
readd(data_hbc) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_hbc) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_hbc)
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
readd(calibration_tbl_hbc)
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
readd(forecast_tbl_hbc) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_hbc)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                    .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                          <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,2,1)(1,0,0)[5]         Test   3.06  19.9  8.28  17.6  3.45  0.43
#> 2         2 ARIMA(0,2,1) W/ XGBOOST ERRORS Test   3.31  21.5  8.95  18.9  3.73  0.44
#> 3         3 ETS(M,AD,M)                    Test   1.98  12.8  5.35  11.9  2.19  0.19
#> 4         4 PROPHET                        Test   5.96  38.5 16.1   31.2  6.5   0.46
```

### Next week forecast

``` r
readd(two_week_fc_hbc)
#> # A tibble: 6 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 hbc     2021-07-23   15.1  11.5  18.7 ETS(M,AD,M)
#> 2 hbc     2021-07-26   15.3  11.6  18.9 ETS(M,AD,M)
#> 3 hbc     2021-07-27   15.3  11.7  18.9 ETS(M,AD,M)
#> 4 hbc     2021-07-28   15.3  11.7  18.9 ETS(M,AD,M)
#> 5 hbc     2021-07-29   15.2  11.6  18.8 ETS(M,AD,M)
#> 6 hbc     2021-07-30   15.2  11.6  18.8 ETS(M,AD,M)
```


# Forecast BVH price

### Plot

``` r
readd(data_BVH) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_BVH) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_BVH)
#> # Modeltime Table
#> # A tibble: 4 x 3
#>   .model_id .model   .model_desc                   
#>       <int> <list>   <chr>                         
#> 1         1 <fit[+]> ARIMA(0,1,2)                  
#> 2         2 <fit[+]> ARIMA(1,1,0) W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                   
#> 4         4 <fit[+]> PROPHET
```

### Calibration

``` r
readd(calibration_tbl_BVH)
#> # Modeltime Table
#> # A tibble: 4 x 5
#>   .model_id .model   .model_desc                    .type .calibration_data
#>       <int> <list>   <chr>                          <chr> <list>           
#> 1         1 <fit[+]> ARIMA(0,1,2)                   Test  <tibble [59 x 4]>
#> 2         2 <fit[+]> ARIMA(1,1,0) W/ XGBOOST ERRORS Test  <tibble [59 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                    Test  <tibble [59 x 4]>
#> 4         4 <fit[+]> PROPHET                        Test  <tibble [59 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_BVH) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_BVH)$`_data`
#> # A tibble: 4 x 9
#>   .model_id .model_desc                    .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                          <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(0,1,2)                   Test   2.85  4.85  3.62  4.71  3.44  0   
#> 2         2 ARIMA(1,1,0) W/ XGBOOST ERRORS Test   2.94  5.02  3.73  4.85  3.61  0.69
#> 3         3 ETS(M,AD,M)                    Test   2.84  4.83  3.61  4.7   3.42  0   
#> 4         4 PROPHET                        Test   7.25 11.8   9.2  12.6   7.76  0.49
```

### Next week forecast

``` r
readd(two_week_fc_BVH)
#> # A tibble: 5 x 6
#>   .ticker .index     .value  .low .high .model_desc
#>   <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#> 1 BVH     2022-01-03   56.1  50.5  61.8 ETS(M,AD,M)
#> 2 BVH     2022-01-04   56.2  50.6  61.9 ETS(M,AD,M)
#> 3 BVH     2022-01-05   56.5  50.8  62.1 ETS(M,AD,M)
#> 4 BVH     2022-01-06   56.1  50.4  61.7 ETS(M,AD,M)
#> 5 BVH     2022-01-07   55.6  49.9  61.2 ETS(M,AD,M)
```

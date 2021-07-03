
# Forecast hcm price

### Plot

``` r
readd(data_hcm) %>%
  plot_time_series(date, value, .interactive = interactive)
```

![](Readme_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Divide data to train/ test

``` r
readd(splits_hcm) %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

![](Readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

### Modeltime Table

``` r
readd(models_tbl_hcm)
#> # Modeltime Table
#> # A tibble: 5 x 3
#>   .model_id .model   .model_desc                             
#>       <int> <list>   <chr>                                   
#> 1         1 <fit[+]> ARIMA(1,1,3)(1,0,1)[5]                  
#> 2         2 <fit[+]> ARIMA(0,1,2)(1,0,1)[5] W/ XGBOOST ERRORS
#> 3         3 <fit[+]> ETS(M,AD,M)                             
#> 4         4 <fit[+]> PROPHET                                 
#> 5         5 <fit[+]> LM
```

### Calibration

``` r
readd(calibration_tbl_hcm)
#> # Modeltime Table
#> # A tibble: 5 x 5
#>   .model_id .model   .model_desc                              .type .calibration_data 
#>       <int> <list>   <chr>                                    <chr> <list>            
#> 1         1 <fit[+]> ARIMA(1,1,3)(1,0,1)[5]                   Test  <tibble [131 x 4]>
#> 2         2 <fit[+]> ARIMA(0,1,2)(1,0,1)[5] W/ XGBOOST ERRORS Test  <tibble [131 x 4]>
#> 3         3 <fit[+]> ETS(M,AD,M)                              Test  <tibble [131 x 4]>
#> 4         4 <fit[+]> PROPHET                                  Test  <tibble [131 x 4]>
#> 5         5 <fit[+]> LM                                       Test  <tibble [131 x 4]>
```

### Forecast (Testing Set)

``` r
readd(forecast_tbl_hcm) %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -Inf
```

![](Readme_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Accuracy table

``` r
readd(accuracy_tbl_hcm)$`_data`
#> # A tibble: 5 x 9
#>   .model_id .model_desc                              .type   mae  mape  mase smape  rmse   rsq
#>       <int> <chr>                                    <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1         1 ARIMA(1,1,3)(1,0,1)[5]                   Test   6.1   17.2  7.51  19.6  7.75  0.09
#> 2         2 ARIMA(0,1,2)(1,0,1)[5] W/ XGBOOST ERRORS Test   5.85  16.4  7.2   18.6  7.55  0   
#> 3         3 ETS(M,AD,M)                              Test   5.65  15.8  6.95  17.9  7.36  0.07
#> 4         4 PROPHET                                  Test  16.7   50.1 20.5   67.6 17.5   0.34
#> 5         5 LM                                       Test   9.32  27.3 11.5   32.3 10.4   0.44
```

### Next week forecast

``` r
readd(two_week_fc_hcm)
#> # A tibble: 16 x 6
#>    .ticker .index     .value  .low .high .model_desc
#>    <chr>   <date>      <dbl> <dbl> <dbl> <chr>      
#>  1 hcm     2021-07-03   49.1  36.9  61.2 ETS(M,AD,M)
#>  2 hcm     2021-07-04   49.2  37.1  61.3 ETS(M,AD,M)
#>  3 hcm     2021-07-05   49.3  37.1  61.4 ETS(M,AD,M)
#>  4 hcm     2021-07-06   49.4  37.2  61.5 ETS(M,AD,M)
#>  5 hcm     2021-07-07   49.4  37.2  61.5 ETS(M,AD,M)
#>  6 hcm     2021-07-08   49.4  37.3  61.6 ETS(M,AD,M)
#>  7 hcm     2021-07-09   49.5  37.4  61.6 ETS(M,AD,M)
#>  8 hcm     2021-07-10   49.5  37.4  61.6 ETS(M,AD,M)
#>  9 hcm     2021-07-11   49.5  37.4  61.6 ETS(M,AD,M)
#> 10 hcm     2021-07-12   49.5  37.4  61.6 ETS(M,AD,M)
#> 11 hcm     2021-07-13   49.5  37.3  61.6 ETS(M,AD,M)
#> 12 hcm     2021-07-14   49.5  37.4  61.6 ETS(M,AD,M)
#> 13 hcm     2021-07-15   49.4  37.3  61.6 ETS(M,AD,M)
#> 14 hcm     2021-07-16   49.6  37.4  61.7 ETS(M,AD,M)
#> 15 hcm     2021-07-17   49.6  37.4  61.7 ETS(M,AD,M)
#> 16 hcm     2021-07-18   49.6  37.5  61.7 ETS(M,AD,M)
```

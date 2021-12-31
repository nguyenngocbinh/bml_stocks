
#' @param ticker_name name of ticker.
#' @examples
#' bml_template_report("acb")
bml_template_report <-  function(ticker_name){
  
  line <- paste0(
    
    '---
output: github_document
editor_options: 
chunk_output_type: console
---
  
  
```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

```{r setup, include = FALSE}
library(xgboost)
library(drake)
library(tidymodels)
library(modeltime)
library(tidyverse)
library(tidyquant)
library(lubridate)
library(timetk)
library(modeltime.ensemble)
library(dplyr)
# R.utils::sourceDirectory("D:/R/bml_stocks/R/")
# R.utils::sourceDirectory("R/")
interactive <- FALSE
```

# Forecast ', ticker_name, ' price

### Plot
```{r}
readd(data_',ticker_name,') %>%
  plot_time_series(date, value, .interactive = interactive)
```

### Divide data to train/ test

```{r}
readd(splits_',ticker_name,') %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, value, .interactive = FALSE)
```

### Modeltime Table

```{r}
readd(models_tbl_',ticker_name,')
```

### Calibration
```{r}
readd(calibration_tbl_',ticker_name,')
```


### Forecast (Testing Set)
```{r}

readd(forecast_tbl_',ticker_name,') %>% 
  plot_modeltime_forecast(.legend_max_width = 25, 
                           .interactive      = interactive)
```

### Accuracy table
```{r}
readd(accuracy_tbl_',ticker_name,')$`_data`

```
### Next week forecast
```{r}
readd(two_week_fc_',ticker_name,')
```
'
  )

write(line,
      file = paste0("vignettes/", ticker_name, "/Readme.Rmd"),
      append = FALSE)

}

#' @title Create readme form
#' 
bml_create_readme_file <- function(){
  title = '
---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

```{r setup, include = FALSE}
library(drake)
```

# FORECAST STOCKS PRICE
  '
write(title,
      file = "Readme.Rmd",
      append = FALSE)



}

#' @title Add prediction of each stock to general readme
#' @param ticker_name name of ticker.
#' @examples
bml_readme_add_ticker <- function(ticker_name){
  line = paste0('
### ',stringr::str_to_upper(ticker_name),'
```{r}
readd(two_week_fc_',ticker_name,') %>%  knitr::kable()
```
')
  write(line,
        file = "Readme.Rmd",
        append = TRUE)
  
}


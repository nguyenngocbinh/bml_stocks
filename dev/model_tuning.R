# author: 
# - https://www.r-bloggers.com/2020/06/introducing-modeltime-tidy-time-series-forecasting-using-tidymodels/
# - https://www.r-bloggers.com/2021/08/introducing-iterative-nested-forecasting-with-modeltime/
# - https://www.r-bloggers.com/2021/10/tidy-time-series-forecasting-in-r-with-spark/
# - https://www.r-bloggers.com/2021/06/hyperparameter-tuning-forecasts-in-parallel-with-modeltime/
# - https://albertoalmuinha.com/posts/2021-06-28-boostime-tuning/parameter-tuning-boostime/?panelset3=m13


# recipe

model_list_arima_boosted <- list(
  learn_rate = c(0.010, 0.100, 0.350, 0.650),
  trees = c(200, 500)
) %>%
  cross() %>%
  map_dfr(bind_rows) %>%
  create_model_grid(f_model_spec = arima_boost,
                    engine_name  = "auto_arima_xgboost",
                    mode         = "regression")

recipe_spec_1 <- recipe(Weekly_Sales ~ ., data = training(splits)) %>%
  step_timeseries_signature(Date) %>%
  step_rm(Date) %>%
  step_normalize(Date_index.num) %>%
  step_zv(all_predictors()) %>%
  step_dummy(all_nominal_predictors(), one_hot = TRUE)

model_list <- model_list_arima_boosted$.models

model_list


model_wfset <- workflow_set(
  preproc = list(
    recipe_spec_1
  ),
  models = model_list, 
  cross = TRUE
)

model_wfset



dataset_tbl <- walmart_sales_weekly %>%
  select(id, Date, Weekly_Sales) %>% 
  filter(id == '1_1')

dataset_tbl %>% 
  group_by(id) %>%
  plot_time_series(
    .date_var    = Date, 
    .value       = Weekly_Sales, 
    .facet_ncol  = 2, 
    .interactive = FALSE
  )

splits <- time_series_split(
  dataset_tbl, 
  assess     = "6 months", 
  cumulative = TRUE
)

splits %>% 
  tk_time_series_cv_plan() %>% 
  plot_time_series_cv_plan(Date, Weekly_Sales, .interactive = F)



parallel_start(2)

model_parallel_tbl <- model_wfset %>%
  modeltime_fit_workflowset(
    data    = training(splits),
    control = control_fit_workflowset(
      verbose   = TRUE,
      allow_par = TRUE
    )
  )

model_parallel_tbl %>%
  modeltime_forecast(
    new_data    = testing(splits),
    actual_data = dataset_tbl,
    keep_data   = TRUE
  ) %>%
  group_by(id) %>%
  plot_modeltime_forecast(
    .facet_ncol  = 3,
    .interactive = FALSE
  )


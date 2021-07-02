pkgs <-
  c(
    "xgboost",
    "drake",
    "tidymodels",
    "modeltime",
    "tidyverse",
    "tidyquant",
    "lubridate",
    "timetk",
    "modeltime.ensemble"
  )

pkgs_dep <- c(
  "xgboost",
  "drake",
  "tidymodels",
  "modeltime",
  "tidyverse",
  "tidyquant",
  "timetk",
  "modeltime.ensemble"
)

pkgs_sug <- setdiff(pkgs, pkgs_dep)

# Add to description
purrr::map(pkgs_dep, usethis::use_package, type = "Depends")
purrr::map(pkgs_sug, usethis::use_package, type = "Suggests")

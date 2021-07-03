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
    "modeltime.ensemble",
    "visNetwork"
    
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

# Install packages
have.packages <- installed.packages()[, 1]
to.install <- setdiff(pkgs, have.packages)
if (length(to.install) > 0) install.packages(to.install)

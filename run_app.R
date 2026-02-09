#!/usr/bin/env Rscript

# Script to run the Urban Farm Dashboard application
# Usage: Rscript run_app.R

# Load required libraries
required_packages <- c("shiny", "shinydashboard", "DT", "ggplot2", "dplyr")

# Check and install missing packages
missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if(length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, repos = "https://cloud.r-project.org/")
}

# Run the app
message("Starting Urban Farm Dashboard...")
shiny::runApp(launch.browser = TRUE)

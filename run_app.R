#!/usr/bin/env Rscript

# Script to run the Urban Farm Dashboard application
# Usage: Rscript run_app.R

# Load required libraries
required_packages <- c(
  "shiny",
  "shinydashboard",
  "DT",
  "ggplot2",
  "dplyr",
  "googlesheets4",
  "gargle"
)

# Check and install missing packages
missing_packages <- setdiff(required_packages, rownames(installed.packages()))
if(length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, repos = "https://cloud.r-project.org/")
}

# Run the app
message("Starting Urban Farm Dashboard...")
shiny::runApp(launch.browser = TRUE)

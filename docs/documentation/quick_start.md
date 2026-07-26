Quick Start Guide
================

# Quick Start Guide

## Getting Started in 5 Minutes

### 1. Install Required Packages

``` r
install.packages(c(
    "shiny",
    "shinydashboard", 
    "DT",
    "ggplot2",
    "dplyr",
    "googlesheets4",
    "gargle"
))
```

### 2. Run the Application

``` r
# Option 1: From R console
setwd("~/Urban_farm_dashboard")
shiny::runApp()

# Option 2: From command line
Rscript run_app.R

# Option 3: From RStudio
# Open app.R and click "Run App" button
```

The app will automatically open in your browser at
`http://127.0.0.1:XXXX`

### 3. Navigate the Dashboard

The dashboard has five main tabs in the sidebar:

- **Dashboard**: View overview statistics (total chickens, active
  hazards)
- **Chickens**: Manage your flock inventory and health records
- **Hazards**: Track and report farm hazards
- **Farm Risk**: KVC risk calculator, profiles, and crowdsourced
  assessments
- **About**: Learn more about the application

## Key Features at a Glance

### Managing Chickens

1.  Click “Chickens” in the sidebar
2.  Click “Add New Chicken” button
3.  Fill in chicken details (name, breed, age, health status)
4.  Confirm and view in inventory table
5.  Data is automatically saved to `data/chickens.csv`

### Reporting Hazards

1.  Click “Hazards” in the sidebar
2.  Click “Report New Hazard” button
3.  Describe the hazard, set severity, and status
4.  Submit to add to hazard log
5.  Use filters to view hazards by status or severity

### Farm Risk Assessment

#### Job Risk Calculator

1.  Select a farm zone (for example, “Sheep Yards” or “Chicken Coop”)
2.  Check off all tools needed for the job
3.  Review:
    - Area Max Hazard Score
    - Highest Tool Risk Class
    - Operational Status (STANDARD / HIGH / CRITICAL)
    - Detailed hazard table with controls

#### Compare Risk Profiles

1.  Select a tool from the dropdown
2.  View comparison chart: Teacher Baseline vs AI Engine vs Historical
    vs Live Class
3.  Check the variance table

#### Log Assessment

1.  Select a tool being assessed
2.  Choose the risk slider value (1-5)
3.  Enter the spatial coordinate or landmark
4.  Write your justification
5.  Click “Submit To Master Registry”
6.  View the submission in the live feed table

## Data and Offline Mode

Data is automatically saved in two places:

- Local CSV files in `data/` folder (always)
- Google Sheets (if configured with environment variables)

If Google Sheets is unavailable, the app automatically falls back to
local CSV files.

## Tips

- Use the **Refresh** button to reload data from storage
- Filter hazards by **status** and **severity** for better insights
- Check visualizations in each module for patterns
- Enable offline mode by not setting Google Sheets environment variables
- Data persists even if you restart the app

## Common Issues

**“Package not found” error**

``` r
install.packages("package_name")
```

**Port already in use**

``` r
shiny::runApp(port = 3839)
```

**No data showing**

- Check `data/` folder exists
- Restart the app
- See [Data Schema](data_schema.md) for file format

## Next Steps

- Read [Data Schema](data_schema.md) to understand data structure
- See [Deployment Guide](deployment.md) to host online
- Check [Development Guide](development.md) to add features

------------------------------------------------------------------------

[← Back to Home](../README.md)

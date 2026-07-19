# Quick Start Guide

## Getting Started in 5 Minutes

### 1. Install Required Packages

```r
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

From your terminal in the project directory:

```bash
Rscript run_app.R
```

Or from R console:
```r
setwd("~/Urban_farm_dashboard")
shiny::runApp()
```

Or from RStudio: Open `app.R` and click "Run App" button

### 3. Navigate the Dashboard

The app will open at `http://127.0.0.1:XXXX` with these tabs:

- **Dashboard** — Overview statistics
- **Chickens** — Manage flock inventory
- **Hazards** — Track farm hazards
- **Farm Risk** — KVC risk calculator & assessments
- **About** — More information

## Quick Tasks

### Add a Chicken

1. Click **Chickens** tab
2. Click "Add New Chicken"
3. Fill in: Name, Breed, Age (months), Health Status
4. Confirm — data saves automatically to CSV

### Report a Hazard

1. Click **Hazards** tab
2. Click "Report New Hazard"
3. Describe, set severity, choose status
4. Submit — appears in hazard log

### Use KVC Risk Calculator

1. Click **Farm Risk** tab → **Job Risk Calculator**
2. Select a zone (e.g., "Sheep Yards")
3. Check tools needed
4. View risk scores & hazard table
5. Check tool-specific controls

## Tips

- Data saves automatically to `data/` folder
- Use **Refresh** buttons to reload from storage
- Enable Google Sheets for live collaborative data (optional)
- App works offline without Google Sheets

## Common Issues

**"Package not found" error**
```r
install.packages("package_name")
```

**Port already in use**
```r
shiny::runApp(port = 3839)  # Use different port
```

**No data showing**
- Check `data/` folder exists
- Restart the app
- See [Data Schema](data_schema.md) for file format

## Next Steps

- Read [Data Schema](data_schema.md) to understand data structure
- See [Deployment Guide](deployment.md) to host online
- Check [Development Guide](development.md) to add features

---

[← Back to Home](../README.md)

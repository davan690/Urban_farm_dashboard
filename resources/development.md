# Development Guide

## Project Structure

```
Urban_farm_dashboard/
├── app.R                              # Main application file - entry point
├── run_app.R                          # Helper script to run the app
├── DESCRIPTION                        # Package metadata and dependencies
├── Urban_farm_dashboard.Rproj         # RStudio project file
├── R/
│   └── helpers.R                      # Utility functions (Google Sheets + CSV)
├── modules/
│   ├── chickens_module.R              # Chicken management module
│   ├── hazards_module.R               # Hazard tracking module
│   └── farm_risk_module.R             # KVC Farm Risk Dashboard module
├── data/
│   ├── chickens.csv                   # Chicken inventory data
│   ├── hazards.csv                    # Hazard log data
│   ├── area_hazards.csv               # Farm zone hazard reference
│   ├── tool_registry.csv              # Farm tool risk registry
│   └── risk_submissions.csv           # Student risk assessments
├── www/
│   └── custom.css                     # Custom styling (including KVC styles)
├── resources/
│   ├── data_schema.md                 # Data structure documentation
│   ├── development.md                 # This file
│   ├── deployment.md                  # Deployment guide
│   ├── quick_start.Rmd                # Quick start guide
│   ├── google_sheets_setup.Rmd        # GSheets API setup
│   ├── kvc_farm_risk_matrix_crowdsourced_dashboard.html  # Static dashboard
│   └── prompt_guidelines.md           # GitHub repository setup guide
└── docs/
    └── [GitHub Pages hosted site - see docs/README.md]
```

## Code Architecture

### Modular Design

The application uses Shiny modules to organize code:

- **Modules** are defined with two functions:
  - `moduleUI()`: Defines the user interface
  - `moduleServer()`: Contains server logic
  
- Each module is independent and reusable

### Data Flow

```
CSV/GSheets → load_*() → reactiveVal/reactiveValues() → UI rendering
                                                           ↓
                                                    User actions
                                                           ↓
                                                    save_*()  → CSV/GSheets
```

1. **Loading**: Data is loaded from Google Sheets or CSV files via helper functions
2. **Display**: Data is shown in tables and charts using reactive values
3. **Updates**: User actions trigger updates to reactive values
4. **Saving**: Changes are persisted to local CSV (always) and Google Sheets (if available)

### Three-Tier Data Strategy

1. **Primary**: Google Sheets (live collaborative data)
2. **Local Fallback**: CSV files (always written as backup)
3. **Error Handling**: Graceful degradation if GSheets unavailable

## Modules Overview

### Chickens Module (`modules/chickens_module.R`)
- Add/edit chicken inventory
- Health status tracking
- Visualizations (health & breed distribution)

### Hazards Module (`modules/hazards_module.R`)
- Report and track farm hazards
- Severity and status filtering
- Statistical overview charts

### Farm Risk Module (`modules/farm_risk_module.R`) [NEW]
- **Tab 1**: Job Risk Calculator (zone selection + tool checklist)
- **Tab 2**: Risk Profile Comparison (4-way analysis chart)
- **Tab 3**: Live Crowdsourced Assessment Log (student submissions)

## Adding New Features

### Creating a New Module

1. Create file `modules/new_module.R`:

```r
# New Module UI
newModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    # Your UI here
  )
}

# New Module Server
newModuleServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Your server logic here
  })
}
```

2. Source module in `app.R`:
```r
source("modules/new_module.R", local = TRUE)
```

3. Add to sidebar menu:
```r
menuItem("New Feature", tabName = "newfeature", icon = icon("star"))
```

4. Add to UI tabItems:
```r
tabItem(
  tabName = "newfeature",
  newModuleUI("newfeature")
)
```

5. Call in server:
```r
newModuleServer("newfeature")
```

### Adding Helper Functions

Add new utility functions to `R/helpers.R`:

```r
#' Load data from source
#' @param data_type Type of data to load
#' @return Data frame with data
load_new_data <- function() {
  # Try GSheets first
  if (gsheets_enabled()) {
    result <- tryCatch({
      ensure_gsheets_auth()
      tabs <- get_gsheets_tabs()
      sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
      data <- googlesheets4::read_sheet(sheet_id, sheet = tabs$new_data)
      as.data.frame(data, stringsAsFactors = FALSE)
    }, error = function(e) {
      message("[offline] new_data: ", conditionMessage(e))
      NULL
    })
    if (!is.null(result)) return(result)
  }
  
  # Fall back to CSV
  file_path <- "data/new_data.csv"
  if (file.exists(file_path)) {
    return(read.csv(file_path, stringsAsFactors = FALSE))
  }
  
  # Return empty data frame
  data.frame()
}
```

### Adding New Data Tables

1. Create CSV in `data/` with schema
2. Add GSheets tab name to `get_gsheets_tabs()`
3. Create `load_*()` helper function with offline fallback
4. Create `ensure_*_columns()` validation function
5. Use in modules as `load_*()` in reactive expressions

## Testing

### Manual Testing

1. Run the app locally:
```r
shiny::runApp()
```

2. Test each feature:
   - Add/view data in each module
   - Test filters and searches
   - Verify data persistence (check CSV written)
   - Check GSheets sync if configured
   - Verify responsive design

### Offline Testing

Test CSV fallback without GSheets:
```r
# Clear environment variables
Sys.unsetenv("GSHEETS_SHEET_ID")
# Run app - should use local CSVs only
shiny::runApp()
```

### Data Validation

Test validation functions:
```r
source("R/helpers.R")
validate_chicken_entry("Test", "Breed", 5)
```

## Styling

### CSS Customization

Edit `www/custom.css` to customize appearance:

```css
/* Custom styles */
.my-custom-class {
  color: #065f46;
  font-weight: bold;
}
```

Apply in UI:
```r
div(class = "my-custom-class", "Content")
```

### Dashboard Theme

Change theme color in `app.R`:
```r
dashboardPage(
  skin = "green",  # Options: blue, black, purple, green, red, yellow
  ...
)
```

### KVC Risk Dashboard Styles

The farm risk module uses custom KVC styling:
- Emerald green accent color (#065f46)
- Risk score colour helpers (.risk-low, .risk-medium, .risk-high)
- Tool control cards with consistent formatting
- Pulse animation for LIVE badge

## Best Practices

### Code Style

- Use 2 spaces for indentation
- Use descriptive variable names
- Comment complex logic
- Keep functions focused and small

### Module Design

- Keep modules independent
- Use clear naming conventions
- Document module parameters
- Handle errors gracefully
- Use try/tryCatch for external dependencies

### Data Management

- Always validate user input
- Use proper error handling
- Provide user feedback (notifications)
- Back up data regularly
- Write CSV before GSheets (data safety first)

### Performance

- Use reactive values efficiently
- Avoid unnecessary re-renders
- Cache expensive computations
- Use `debounce()` for frequent updates
- Optimize data loading

## Debugging

### Debugging in RStudio

1. Set breakpoints in RStudio
2. Run app in debug mode
3. Use `browser()` for interactive debugging

### Console Logging

Add print statements for debugging:
```r
cat("Debug: value =", some_value, "\n")
message("[INFO] Loading data from ", file_path)
```

### Common Issues

**Module not loading**
- Check if module file is sourced in app.R
- Verify function names match
- Check for syntax errors

**Data not saving**
- Verify file permissions in data/ directory
- Check if data directory exists
- Ensure CSV format is correct
- Check both CSV and GSheets (if configured)

**Google Sheets errors**
- Verify GSHEETS_SHEET_ID environment variable
- Check service account has edit access
- Verify sheet tab names match configuration
- Check network connectivity
- App will fall back to CSV automatically

**UI not updating**
- Check reactive dependencies
- Verify observe/observeEvent setup
- Use `reactiveVal()` or `reactiveValues()` appropriately
- Check DT table renderDT wrapping

## Environment Variables

### Required for Google Sheets Integration

```bash
# Sheet ID (from Google Sheets URL)
export GSHEETS_SHEET_ID="1ABC...XYZ"

# Tab names (optional - defaults shown)
export GSHEETS_CHICKENS_TAB="Chickens"
export GSHEETS_HAZARDS_TAB="Hazards"
export GSHEETS_AREA_HAZARDS_TAB="AreaHazards"
export GSHEETS_TOOL_REGISTRY_TAB="ToolRegistry"
export GSHEETS_RISK_SUBMISSIONS_TAB="RiskSubmissions"

# Service account JSON (path or raw JSON)
export GSHEETS_SERVICE_JSON="/path/to/service-account-key.json"
# OR
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### Optional Configuration

```bash
# Data directory (default: ./data)
export DATA_DIR="/path/to/data"
```

## Contributing

### Workflow

1. Create a feature branch
2. Make changes following code style
3. Test thoroughly (online and offline modes)
4. Update documentation
5. Commit with clear messages
6. Submit pull request

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Functions are documented
- [ ] Changes are tested (both modes)
- [ ] No console errors or warnings
- [ ] Documentation updated
- [ ] CSV fallback works
- [ ] GSheets integration tested (if applicable)
- [ ] Backwards compatible

## Resources

- [Shiny Documentation](https://shiny.rstudio.com/)
- [Shiny Modules](https://shiny.rstudio.com/articles/modules.html)
- [shinydashboard Documentation](https://rstudio.github.io/shinydashboard/)
- [DT Package](https://rstudio.github.io/DT/)
- [ggplot2 Reference](https://ggplot2.tidyverse.org/)
- [googlesheets4 Package](https://googlesheets4.tidyverse.org/)
- [gargle Authentication](https://gargle.r-lib.org/)

# Development Guide

## Project Architecture

### Directory Structure

```
Urban_farm_dashboard/
├── app.R                    # Main Shiny application
├── run_app.R                # Launch helper
├── DESCRIPTION              # Package metadata
├── R/
│   └── helpers.R            # Data functions
├── modules/
│   ├── chickens_module.R    # Chicken management module
│   ├── hazards_module.R     # Hazard tracking module
│   └── farm_risk_module.R   # KVC risk assessment module
├── data/
│   ├── chickens.csv
│   ├── hazards.csv
│   ├── area_hazards.csv
│   ├── tool_registry.csv
│   └── risk_submissions.csv
├── documentation/          # Source documentation (editable)
├── www/
│   └── custom.css           # Dashboard styles
└── docs/                    # Published GitHub-facing output
```

## Core Concepts

Project documentation is authored in `documentation/` and published to `docs/documentation/`.

### Three-Tier Data Strategy

1. **CSV (Local)**
   - Written immediately
   - Always succeeds
   - No dependency on network

2. **Google Sheets (Optional)**
   - Attempted after CSV
   - Enables live collaboration
   - Network errors fail gracefully

3. **Automatic Fallback**
   - On GSheets error: continues with CSV
   - User never loses data
   - Automatic retry on next request

### Shiny Module Pattern

Each feature is a self-contained module:

```r
# Module UI
chickensUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Chickens"),
    actionButton(ns("add"), "Add New")
  )
}

# Module Server
chickensServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Reactive logic here
  })
}
```

## Adding New Features

### Step 1: Create Module File

Create `modules/myfeature_module.R`:

```r
myFeatureUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("My Feature"),
    # UI elements
  )
}

myFeatureServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Server logic
  })
}
```

### Step 2: Add to app.R

```r
# Source module
source("modules/myfeature_module.R")

# In UI: Add menu item
menuItem("My Feature", tabName = "myfeature", icon = icon("star"))

# In tabItems: Add tab
tabItem(tabName = "myfeature", myFeatureUI("myfeature"))

# In server: Initialize module
myFeatureServer("myfeature")
```

### Step 3: Add Data Functions (if needed)

In `R/helpers.R`:

```r
load_mydata <- function() {
  path <- "data/mydata.csv"
  if (file.exists(path)) {
    read.csv(path, stringsAsFactors = FALSE)
  } else {
    data.frame()  # Empty fallback
  }
}

save_mydata <- function(data) {
  # Write CSV first (always succeeds)
  write.csv(data, "data/mydata.csv", row.names = FALSE)
  
  # Attempt GSheets write (optional)
  tryCatch({
    googlesheets4::write_sheet(
      data, 
      ss = Sys.getenv("GOOGLE_SHEETS_ID"),
      sheet = "MyData"
    )
  }, error = function(e) {
    warning(paste("GSheets write failed:", e$message))
  })
}
```

## Code Style Guide

### Naming Conventions

- **Variables**: snake_case
- **Functions**: camelCase
- **Modules**: feature_module.R
- **Module functions**: featureUI(), featureServer()

### Comments

```r
# Section header for major blocks
# Brief description of what follows

# Mark temporary code with TODO:
# TODO: Replace with actual API call

# Mark workarounds with WORKAROUND:
# WORKAROUND: Bug in package X, remove when fixed
```

### Error Handling

Always use tryCatch for network operations:

```r
result <- tryCatch({
  googlesheets4::read_sheet(ss, sheet)
}, error = function(e) {
  warning(paste("Error loading data:", e$message))
  read.csv(fallback_path)  # Fallback
})
```

## Testing

### Manual Testing Workflow

1. **Data layer**: Test load/save functions directly
   ```r
   source("R/helpers.R")
   data <- load_chickens()
   ```

2. **Module layer**: Run module in isolation
   ```r
   source("modules/chickens_module.R")
   chickensUI("test")
   ```

3. **Full app**: Run app.R
   ```bash
   Rscript run_app.R
   ```

### Test Cases for Features

- [ ] Data loads without errors
- [ ] CSV writes successfully
- [ ] GSheets writes attempted (check logs)
- [ ] Fallback works on network error
- [ ] UI responds correctly to user input
- [ ] Tables display without errors
- [ ] Charts render properly
- [ ] No console errors in browser

## Performance Considerations

### Reactive Caching

For expensive operations, use reactive values:

```r
data <- reactive({
  invalidateLater(5000)  # Refresh every 5 seconds
  load_data()
})
```

### Debouncing Input

For user input, debounce expensive reactions:

```r
observeEvent(input$search, {
  invalidateLater(1000)  # Wait 1 second before reacting
  search_results()
})
```

## Debugging

### Enable Debug Logging

In app.R:

```r
options(shiny.error = browser)  # Break on error
options(shiny.trace = TRUE)     # Verbose logging
```

### Check Browser Console

1. Open Dev Tools (F12)
2. Check Console tab for JavaScript errors
3. Network tab shows data requests

### Inspect R Functions

```r
# Print values in reactive
reactive({ 
  cat("Debug:", nrow(df), "rows\n")
  df 
})

# Use browser() to pause execution
browser()
```

## Documentation Standards

- Document all public functions with comments
- Include parameter descriptions
- Explain non-obvious logic
- Update README when adding features
- Note deprecations clearly

### Example Function Doc

```r
#' Load Chickens Data with Fallback
#'
#' Loads chickens from Google Sheets if available,
#' otherwise falls back to local CSV.
#'
#' @return data.frame with columns: id, name, breed, age_months, health_status
#' @examples
#' chickens <- load_chickens()
load_chickens <- function() {
  # ... implementation
}
```

## Deployment Checklist

- [ ] All data loads correctly
- [ ] CSV backups present
- [ ] GSheets integration tested
- [ ] No console errors
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Style guide followed
- [ ] Performance acceptable

## Common Patterns

### Loading Data with Fallback

```r
load_data_safe <- function(sheet_name, csv_file) {
  # Try GSheets first
  data <- tryCatch({
    googlesheets4::read_sheet(ss, sheet = sheet_name)
  }, error = function(e) NULL)
  
  # If GSheets failed, use CSV
  if (is.null(data)) {
    if (file.exists(csv_file)) {
      data <- read.csv(csv_file, stringsAsFactors = FALSE)
    } else {
      data <- data.frame()
    }
  }
  
  return(data)
}
```

### Reactive Form Submission

```r
# In module server
observeEvent(input$submit, {
  new_row <- data.frame(
    id = max(df$id) + 1,
    name = input$name,
    # ... other fields
  )
  
  df <<- rbind(df, new_row)
  save_data(df)
  
  showNotification("Saved!", type = "message")
  shinyjs::reset("form")  # Clear form
})
```

---

[← Back to Home](../README.md) | [Next: Data Schema](data_schema.md)

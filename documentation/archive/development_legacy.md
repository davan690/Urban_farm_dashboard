# Development Guide

## Project Structure

```
Urban_farm_dashboard/
├── app.R                    # Main application file - entry point
├── run_app.R               # Helper script to run the app
├── DESCRIPTION             # Package metadata and dependencies
├── Urban_farm_dashboard.Rproj  # RStudio project file
├── R/
│   └── helpers.R           # Utility functions
├── modules/
│   ├── chickens_module.R   # Chicken management module
│   └── hazards_module.R    # Hazard tracking module
├── data/
│   ├── chickens.csv        # Chicken inventory data
│   └── hazards.csv         # Hazard log data
├── www/
│   └── custom.css          # Custom styling
└── docs/
    ├── quick_start.Rmd     # Quick start guide
    └── deployment.md       # Deployment guide
```

## Code Architecture

### Modular Design

The application uses Shiny modules to organize code:

- **Modules** are defined with two functions:
  - `moduleUI()`: Defines the user interface
  - `moduleServer()`: Contains server logic
  
- Each module is independent and reusable

### Data Flow

1. **Loading**: Data is loaded from CSV files via helper functions
2. **Display**: Data is shown in tables and charts using reactive values
3. **Updates**: User actions trigger updates to reactive values
4. **Saving**: Changes are persisted back to CSV files

## Adding New Features

### Creating a New Module

1. Create file `modules/new_module.R`:

```r
# New Module
newModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    # Your UI here
  )
}

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

3. Add to UI:
```r
tabItem(
  tabName = "newmodule",
  newModuleUI("newmodule")
)
```

4. Call in server:
```r
newModuleServer("newmodule")
```

### Adding Helper Functions

Add new utility functions to `R/helpers.R`:

```r
#' Function description
#' @param param1 Description
#' @return Description
my_new_function <- function(param1) {
  # Implementation
}
```

### Adding New Data Fields

1. Update CSV structure in `data/` directory
2. Update helper functions in `R/helpers.R`
3. Update module UI and server logic
4. Update validation functions if needed

## Testing

### Manual Testing

1. Run the app locally:
```r
shiny::runApp()
```

2. Test each feature:
   - Add/view data in each module
   - Test filters and searches
   - Verify data persistence
   - Check responsive design

### Data Validation

Test validation functions:
```r
source("R/helpers.R")
validate_chicken_entry("Test", "Breed", 5)
validate_hazard_entry("Type", "Description", "High")
```

## Styling

### CSS Customization

Edit `www/custom.css` to customize appearance:

```css
/* Custom styles */
.my-custom-class {
  color: #28a745;
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

### Data Management

- Always validate user input
- Use proper error handling
- Provide user feedback (notifications)
- Back up data regularly

### Performance

- Use reactive values efficiently
- Avoid unnecessary re-renders
- Cache expensive computations
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
print(str(data_frame))
```

### Common Issues

**Module not loading**
- Check if module file is sourced in app.R
- Verify function names match
- Check for syntax errors

**Data not saving**
- Verify file permissions
- Check if data directory exists
- Ensure CSV format is correct

**UI not updating**
- Check reactive dependencies
- Verify observe/observeEvent setup
- Use `reactiveVal()` or `reactiveValues()` appropriately

## Contributing

### Workflow

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Document changes
5. Submit pull request

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Functions are documented
- [ ] Changes are tested
- [ ] No console errors
- [ ] Documentation updated
- [ ] Backwards compatible

## Resources

- [Shiny Documentation](https://shiny.rstudio.com/)
- [Shiny Modules](https://shiny.rstudio.com/articles/modules.html)
- [shinydashboard Documentation](https://rstudio.github.io/shinydashboard/)
- [DT Package](https://rstudio.github.io/DT/)
- [ggplot2 Reference](https://ggplot2.tidyverse.org/)

## Contact

For questions or support:
- Review existing documentation
- Check GitHub issues
- Contact the development team

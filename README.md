# Urban Farm Dashboard

An RShiny application for managing urban farm tasks with a focus on chicken management and hazard tracking.

## Features

- 🐔 **Chicken Management**: Track chicken inventory, health status, and breed information
- ⚠️ **Hazard Management**: Report and monitor farm hazards with severity levels
- 📊 **Data Visualization**: Interactive charts and graphs for insights
- 💾 **Data Persistence**: CSV-based storage for easy data management
- 📱 **Responsive Design**: Works on desktop and mobile devices

## Quick Start

### Installation

1. Install R (version 3.5.0 or higher)
2. Install required packages:

```r
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", "dplyr"))
```

### Running the App

```r
# From R console
shiny::runApp()

# Or open app.R in RStudio and click "Run App"
```

## Project Structure

```
Urban_farm_dashboard/
├── app.R                    # Main application file
├── DESCRIPTION             # Package dependencies
├── README.Rmd              # Comprehensive documentation
├── R/
│   └── helpers.R           # Helper functions
├── modules/
│   ├── chickens_module.R   # Chicken management module
│   └── hazards_module.R    # Hazard management module
├── data/
│   ├── chickens.csv        # Chicken inventory data
│   └── hazards.csv         # Hazard log data
├── docs/
│   └── quick_start.Rmd     # Quick start guide
└── www/
    └── custom.css          # Custom styling
```

## Documentation

For detailed documentation, please see:
- [README.Rmd](README.Rmd) - Complete user guide
- [docs/quick_start.Rmd](docs/quick_start.Rmd) - Quick start guide

## Usage

### Dashboard Overview
View key metrics at a glance:
- Total chickens in inventory
- Active hazards requiring attention
- Tasks scheduled for today

### Managing Chickens
1. Navigate to "Chickens" tab
2. Click "Add New Chicken" to add entries
3. View health and breed distributions
4. Search and sort the inventory table

### Managing Hazards
1. Navigate to "Hazards" tab
2. Click "Report New Hazard" to log issues
3. Filter by status and severity
4. Track resolution progress

## Technologies Used

- **Shiny**: Web application framework for R
- **shinydashboard**: Dashboard layout and components
- **DT**: Interactive data tables
- **ggplot2**: Data visualization
- **dplyr**: Data manipulation

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

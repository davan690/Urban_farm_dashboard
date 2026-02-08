# Documentation Index

Welcome to the Urban Farm Dashboard documentation. This index will help you find the information you need.

## Getting Started

- **[Quick Start Guide](quick_start.Rmd)** - Get up and running in 5 minutes
- **[README (Comprehensive)](../README.Rmd)** - Complete user guide and documentation
- **[README (Summary)](../README.md)** - Quick overview and project information

## For Users

### Basic Usage
- [Quick Start Guide](quick_start.Rmd) - Installation and first steps
- [README.Rmd](../README.Rmd) - Detailed feature documentation
  - Dashboard Overview
  - Managing Chickens
  - Managing Hazards
  - Troubleshooting

### Data Management
- [Data Schema](data_schema.md) - Understanding the data structure
  - Chickens data format
  - Hazards data format
  - Validation rules
  - Backup procedures

## For Developers

### Development
- [Development Guide](development.md) - Contributing to the project
  - Project structure
  - Code architecture
  - Adding new features
  - Testing procedures
  - Best practices

### Deployment
- [Deployment Guide](deployment.md) - Running in production
  - Local development setup
  - Deploying to shinyapps.io
  - Shiny Server deployment
  - Docker deployment
  - Monitoring and maintenance

## Quick Reference

### File Structure
```
Urban_farm_dashboard/
├── app.R                    # Main application
├── run_app.R               # Run script
├── DESCRIPTION             # Dependencies
├── R/helpers.R             # Utility functions
├── modules/                # Shiny modules
├── data/                   # CSV data files
├── www/                    # Static assets
└── docs/                   # Documentation
```

### Key Files
- `app.R` - Application entry point
- `R/helpers.R` - Data management functions
- `modules/chickens_module.R` - Chicken management
- `modules/hazards_module.R` - Hazard tracking
- `data/chickens.csv` - Chicken inventory
- `data/hazards.csv` - Hazard log

### Running the App

```r
# Install dependencies
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", "dplyr"))

# Run application
shiny::runApp()
```

## Support

### Common Tasks

**I want to...**
- **Start using the app** → See [Quick Start Guide](quick_start.Rmd)
- **Understand the features** → See [README.Rmd](../README.Rmd)
- **Add a new chicken** → See [Managing Chickens](../README.Rmd#managing-chickens)
- **Report a hazard** → See [Managing Hazards](../README.Rmd#managing-hazards)
- **Understand the data format** → See [Data Schema](data_schema.md)
- **Deploy to production** → See [Deployment Guide](deployment.md)
- **Add new features** → See [Development Guide](development.md)
- **Troubleshoot issues** → See [README.Rmd - Troubleshooting](../README.Rmd#troubleshooting)

### Getting Help

1. Check the relevant documentation above
2. Review the README.Rmd for detailed information
3. Check GitHub issues
4. Contact the development team

## Document Status

| Document | Last Updated | Status |
|----------|--------------|--------|
| README.md | 2026-02-08 | Current |
| README.Rmd | 2026-02-08 | Current |
| Quick Start | 2026-02-08 | Current |
| Data Schema | 2026-02-08 | Current |
| Development Guide | 2026-02-08 | Current |
| Deployment Guide | 2026-02-08 | Current |

## Contributing to Documentation

To improve documentation:
1. Edit the relevant .md or .Rmd file
2. Follow existing formatting
3. Keep language clear and concise
4. Include examples where helpful
5. Update this index if adding new documents

## License

All documentation is covered under the project's MIT License.

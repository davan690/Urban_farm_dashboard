# 🌾 Urban Farm Dashboard

**Interactive Shiny Application for Farm Management & KVC Student Risk Assessments**

[![GitHub](https://img.shields.io/badge/GitHub-davan690%2FUrban_farm_dashboard-blue)](https://github.com/davan690/Urban_farm_dashboard)
[![License](https://img.shields.io/badge/License-MIT-green)](../LICENSE)
[![R Version](https://img.shields.io/badge/R-%3E%3D3.5.0-lightblue)](https://www.r-project.org/)

---

## 🚀 Quick Links

### For Students
- **[KVC Farm Risk Calculator](kvc-dashboard.html)** — Interactive risk assessment tool
- **[Quick Start Guide](documentation/quick_start.md)** — Get running in 5 minutes
- **[Data Schema](documentation/data_schema.md)** — Understand the data structure

### For Teachers & Developers
- **[Development Guide](documentation/development.md)** — Architecture & code style
- **[Deployment Guide](documentation/deployment.md)** — Deploy to cloud
- **[Google Sheets Setup](documentation/google_sheets_setup.md)** — Enable collaborative data

---

## ✨ Features

### Phase 1: Farm Management
- Chicken inventory & health tracking
- Hazard logging & categorization
- CSV data storage with visualization

### Phase 2: KVC Risk Assessment (NEW)
- Job risk calculator with colour-coded hazards
- Risk profile comparison (Teacher / AI / Historical / Live)
- Crowdsourced student assessments
- Offline-first with optional Google Sheets sync

---

## 🚀 Getting Started

### Prerequisites
- R ≥ 3.5.0
- RStudio (recommended)

### Quick Run
```bash
cd Urban_farm_dashboard
Rscript run_app.R
```

See [Quick Start Guide](documentation/quick_start.md) for more options.

---

## 📖 Documentation

- **[Quick Start](documentation/quick_start.md)** — 5-minute setup
- **[Data Schema](documentation/data_schema.md)** — CSV structure
- **[Development](documentation/development.md)** — Code architecture
- **[Deployment](documentation/deployment.md)** — Production setup
- **[Google Sheets](documentation/google_sheets_setup.md)** — Live data sync

---

## 🌍 Deployment

| Platform | Time | Cost |
|----------|------|------|
| Local | 5 min | Free |
| shinyapps.io | 30 min | $39+/mo |
| Docker | 20 min | Varies |
| Shiny Server | 1 hr | ~$5/mo |

See [Deployment Guide](documentation/deployment.md) for detailed steps.

---

## 📝 License

MIT License — see [LICENSE](../LICENSE)

---

**Last Updated**: 2026-07-19 | [View on GitHub](https://github.com/davan690/Urban_farm_dashboard)
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

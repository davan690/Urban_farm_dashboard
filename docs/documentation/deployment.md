# Deployment Guide

## Overview

This guide covers deploying the Urban Farm Dashboard to production environments.

## Deployment Options

| Platform | Setup Time | Cost | Best For |
|----------|-----------|------|----------|
| Local | 5 min | Free | Development, testing |
| shinyapps.io | 30 min | $39–$499/mo | Cloud hosting, easy setup |
| Shiny Server | 1 hour | ~$5–50/mo (VPS) | On-premise, control |
| Docker | 20 min | Varies | Reproducible environments |
| GitHub Pages | 5 min | Free | Static content (dashboards only) |

---

## Local Development

### Prerequisites

- R ≥ 3.5.0
- RStudio (optional but recommended)

### Installation

```bash
git clone https://github.com/davan690/Urban_farm_dashboard.git
cd Urban_farm_dashboard
Rscript run_app.R
```

App will launch at `http://127.0.0.1:3404`

### Configuration

Edit `run_app.R` to customize:

```r
PORT <- 3404              # Change port if needed
HOST <- "127.0.0.1"       # Change to "0.0.0.0" for LAN access
DEBUG_MODE <- FALSE       # Set TRUE for verbose logging
```

---

## shinyapps.io (Recommended for Cloud)

### Step 1: Create Account

1. Go to [shinyapps.io](https://www.shinyapps.io)
2. Click "Sign Up"
3. Authenticate with GitHub/Google

### Step 2: Install Publisher

In R console:

```r
install.packages("rsconnect")
rsconnect::setAccountInfo(
  name = "YOUR_ACCOUNT",
  token = "YOUR_TOKEN",
  secret = "YOUR_SECRET"
)
```

(Get token/secret from shinyapps.io → Account → Tokens)

### Step 3: Deploy

```r
library(rsconnect)
setwd("~/Urban_farm_dashboard")
deployApp()
```

### Step 4: Set Environment Variables

In shinyapps.io dashboard:

1. Click app name
2. "Settings" → "Environment Variables"
3. Add: `GOOGLE_SHEETS_ID=your_sheet_id`

Your app is now live at: `https://yourname.shinyapps.io/Urban_farm_dashboard/`

### Costs & Scaling

- **Free tier**: 25 active hours/month
- **$39/mo**: 150 active hours, 1 reserved worker
- **$499/mo**: Unlimited hours, 10 workers

---

## Shiny Server (Self-Hosted)

### Prerequisites

- Ubuntu 18.04+ or CentOS 7+
- ~1GB RAM minimum
- Sudo access

### Installation

```bash
# Install R
sudo apt-get install r-base r-base-dev

# Install Shiny Server
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/"
sudo apt-get install shiny-server

# Install packages
sudo R -e "install.packages('shiny')"
```

### Configuration

Edit `/etc/shiny-server/shiny-server.conf`:

```nginx
server {
  listen 3838;
  
  location /urban_farm {
    app_dir /opt/shiny-apps/urban_farm_dashboard;
    log_dir /var/log/shiny-server;
    directory_index on;
  }
}
```

### Deploy

```bash
sudo mkdir -p /opt/shiny-apps
sudo git clone https://github.com/davan690/Urban_farm_dashboard.git \
  /opt/shiny-apps/urban_farm_dashboard
sudo chown -R shiny:shiny /opt/shiny-apps/urban_farm_dashboard
sudo systemctl restart shiny-server
```

App available at: `http://your-server:3838/urban_farm`

---

## Docker (Container Deployment)

### Create Dockerfile

```dockerfile
FROM r-base:4.5

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'dplyr', 'googlesheets4', 'gargle'))"

# Clone app
RUN git clone https://github.com/davan690/Urban_farm_dashboard.git /app

WORKDIR /app

# Expose port
EXPOSE 3404

# Run app
CMD ["Rscript", "run_app.R"]
```

### Build & Run

```bash
# Build image
docker build -t urban-farm-dashboard .

# Run container
docker run -p 3404:3404 urban-farm-dashboard
```

App available at: `http://localhost:3404`

### Push to Docker Hub

```bash
docker tag urban-farm-dashboard yourusername/urban-farm-dashboard:latest
docker push yourusername/urban-farm-dashboard:latest
```

---

## Google Sheets Integration (All Platforms)

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project
3. Enable "Google Sheets API"

### Step 2: Create Service Account

1. IAM & Admin → Service Accounts
2. Create Service Account
3. Create key (JSON format)
4. Download key file

### Step 3: Share Sheets

In your Google Sheet:
1. Get the sheet ID from URL
2. Share with service account email
3. Grant Editor access

### Step 4: Configure App

Set environment variable:

```r
Sys.setenv(GOOGLE_SHEETS_ID = "your_sheet_id")
Sys.setenv(GOOGLE_SHEETS_AUTH = "/path/to/service_account.json")
```

Or add to `.Renviron`:

```
GOOGLE_SHEETS_ID=abc123xyz
GOOGLE_SHEETS_AUTH=/app/secrets/service_account.json
```

### Step 5: Test Connection

```r
source("R/helpers.R")
data <- load_chickens()
```

---

## Security Considerations

### Authentication

For multi-user deployments, add authentication:

```r
# Install shinymanager
install.packages("shinymanager")
library(shinymanager)

ui <- secure_app(ui, enable_admin = TRUE)

server <- function(input, output, session) {
  # Your app code
}
```

### HTTPS / SSL

For production:

1. **shinyapps.io**: Automatic SSL
2. **Shiny Server**: Use nginx as reverse proxy
3. **Docker**: Use Let's Encrypt + nginx

### Data Protection

- ✅ Keep `service_account.json` secure
- ✅ Use `.gitignore` for secrets
- ✅ Don't commit credentials
- ✅ Use environment variables
- ✅ Rotate API keys regularly

### Firewall Rules

```bash
# Allow only your IP to access admin panel
sudo ufw allow from 203.0.113.0/24 to any port 3838
sudo ufw default deny incoming
```

---

## Monitoring & Maintenance

### Health Checks

```r
# Add to app.R
observeEvent(input$refresh_data, {
  tryCatch({
    load_chickens()
    load_hazards()
    showNotification("✓ Data loaded successfully", type = "message")
  }, error = function(e) {
    showNotification(paste("✗ Error:", e$message), type = "error")
  })
})
```

### Log Files

- **shinyapps.io**: Built-in log viewer
- **Shiny Server**: `/var/log/shiny-server/`
- **Docker**: `docker logs container_id`

### Uptime Monitoring

Use free services:

- [UptimeRobot](https://uptimerobot.com) — Monitor endpoint
- [StatusCake](https://www.statuscake.com) — Alerts
- [Pingdom](https://www.pingdom.com) — Performance metrics

---

## Troubleshooting

### "Connection refused" on port 3404

```bash
# Check if port in use
lsof -i :3404

# Use different port
Rscript run_app.R --port 3839
```

### "Package not found" error

Install missing packages:

```r
install.packages("package_name")
```

For Docker, add to Dockerfile:

```dockerfile
RUN R -e "install.packages('missing_package')"
```

### Google Sheets authentication error

```r
# Check service account key
gargle::credentials_app_default()

# Force re-authentication
googlesheets4::gs4_auth(new_user = TRUE)
```

### High memory usage

Optimize:

```r
# Limit active connections
options(shiny.maxRequestSize = 5 * 1024^2)  # 5MB max

# Reduce refresh frequency
invalidateLater(30000)  # 30 seconds instead of 5
```

---

## Performance Tuning

### Database Optimization

For large datasets, consider:

```r
# Use DBI/RSQLite instead of CSV for 1M+ rows
library(DBI)
con <- dbConnect(RSQLite::SQLite(), "data.db")
```

### Caching

```r
# Cache expensive computations
computation <- memoise::memoise(function() {
  expensive_operation()
})
```

### Parallel Processing

```r
# Use future for background jobs
future::plan(multisession)
result %<-% {
  slow_operation()
}
```

---

## Rollback Procedure

If something breaks in production:

```bash
# Stop app
sudo systemctl stop shiny-server

# Revert to previous version
git revert HEAD

# Restart
sudo systemctl start shiny-server
```

---

## Production Checklist

- [ ] All tests pass
- [ ] Data backups configured
- [ ] Google Sheets integration working
- [ ] HTTPS/SSL enabled
- [ ] Error logging enabled
- [ ] Monitoring/alerts set up
- [ ] Documentation updated
- [ ] Performance acceptable
- [ ] Security review completed
- [ ] Backup procedure documented

---

[← Back to Home](../README.md) | [Next: Quick Start](quick_start.md)

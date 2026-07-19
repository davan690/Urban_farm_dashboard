# Urban Farm Dashboard - Deployment Guide

## Local Development

### Prerequisites
- R (>= 3.5.0)
- RStudio (recommended)
- Required packages: shiny, shinydashboard, DT, ggplot2, dplyr, googlesheets4, gargle

### Running Locally
```r
# Install dependencies
install.packages(c(
  "shiny", "shinydashboard", "DT", "ggplot2", "dplyr",
  "googlesheets4", "gargle"
))

# Run app
shiny::runApp()
```

## Deploying to shinyapps.io

### Setup
1. Create account at https://www.shinyapps.io/
2. Install rsconnect package:
```r
install.packages("rsconnect")
```

3. Configure account (get token from shinyapps.io account settings):
```r
rsconnect::setAccountInfo(
  name="<ACCOUNT>",
  token="<TOKEN>",
  secret="<SECRET>"
)
```

### Google Sheets Integration (Optional)

This app can read/write to Google Sheets using a service account. You will need:

1. Create a Google Cloud project and enable the Google Sheets API.
2. Create a service account and download the JSON key.
3. Share the target Google Sheet with the service account email (edit access).
4. Create the required sheet tabs:
   - `Chickens` – Chicken inventory
   - `Hazards` – Hazard log
   - `AreaHazards` – Farm zone hazards reference
   - `ToolRegistry` – Tool risk ratings
   - `RiskSubmissions` – Student assessments
5. Add these environment variables in shinyapps.io dashboard:

```
GSHEETS_SHEET_ID=<your-sheet-id>
GSHEETS_CHICKENS_TAB=Chickens
GSHEETS_HAZARDS_TAB=Hazards
GSHEETS_AREA_HAZARDS_TAB=AreaHazards
GSHEETS_TOOL_REGISTRY_TAB=ToolRegistry
GSHEETS_RISK_SUBMISSIONS_TAB=RiskSubmissions
GSHEETS_SERVICE_JSON=<contents of the service account json>
```

**Note**: 
- `GSHEETS_SERVICE_JSON` should be the raw JSON string. Keep it private.
- Without `GSHEETS_SHEET_ID`, the app uses local CSV files automatically.

### Deploy
```r
# Deploy the application
rsconnect::deployApp(
  appDir = ".",
  appName = "urban-farm-dashboard",
  account = "<ACCOUNT>"
)
```

## Deploying to Shiny Server

### Requirements
- Shiny Server installed on server
- R and required packages installed
- Systemd or init.d for process management

### Steps
1. Copy application files to server:
```bash
scp -r Urban_farm_dashboard user@server:/srv/shiny-server/
```

2. Install dependencies:
```bash
sudo R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'dplyr', 'googlesheets4', 'gargle'))"
```

3. Ensure proper permissions:
```bash
chmod -R 755 /srv/shiny-server/Urban_farm_dashboard
chown -R shiny:shiny /srv/shiny-server/Urban_farm_dashboard
```

4. Create/update Shiny Server config if needed:
```bash
# /etc/shiny-server/shiny-server.conf
server {
  listen 3838;
  location /urban-farm-dashboard {
    app_dir /srv/shiny-server/Urban_farm_dashboard;
    log_dir /var/log/shiny-server;
  }
}
```

5. Restart Shiny Server:
```bash
sudo systemctl restart shiny-server
```

## Docker Deployment

### Dockerfile Example
```dockerfile
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'dplyr', 'googlesheets4', 'gargle'), repos='https://cloud.r-project.org/')"

# Copy app files
COPY . /srv/shiny-server/urban-farm-dashboard

# Set working directory
WORKDIR /srv/shiny-server/urban-farm-dashboard

# Expose port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server"]
```

### Build and Run
```bash
# Build image
docker build -t urban-farm-dashboard .

# Run container
docker run -d \
  -p 3838:3838 \
  -e GSHEETS_SHEET_ID="your-sheet-id" \
  -e GSHEETS_SERVICE_JSON="your-service-json" \
  --name urban-farm-dashboard \
  urban-farm-dashboard
```

### Docker Compose Example
```yaml
version: '3'
services:
  app:
    build: .
    ports:
      - "3838:3838"
    environment:
      - GSHEETS_SHEET_ID=${GSHEETS_SHEET_ID}
      - GSHEETS_SERVICE_JSON=${GSHEETS_SERVICE_JSON}
    volumes:
      - ./data:/srv/shiny-server/urban-farm-dashboard/data
    restart: unless-stopped
```

## Environment Variables

### Google Sheets Configuration (Optional)

```bash
# Sheet ID (from Google Sheets URL)
export GSHEETS_SHEET_ID="1ABC...XYZ"

# Tab/Sheet names (optional - defaults shown)
export GSHEETS_CHICKENS_TAB="Chickens"
export GSHEETS_HAZARDS_TAB="Hazards"
export GSHEETS_AREA_HAZARDS_TAB="AreaHazards"
export GSHEETS_TOOL_REGISTRY_TAB="ToolRegistry"
export GSHEETS_RISK_SUBMISSIONS_TAB="RiskSubmissions"

# Service account authentication (use ONE of these)
export GSHEETS_SERVICE_JSON="<raw JSON content>"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### Data Storage Configuration

```bash
# Data directory (default: ./data)
export DATA_DIR="/path/to/data"
```

### Offline Mode

To run purely in offline mode (no Google Sheets):
- Do NOT set `GSHEETS_SHEET_ID`
- The app uses local CSV files automatically
- Data is always written to CSV as backup

## Data Backup Strategy

### Local CSV Backups (Automatic)

The app automatically:
- Writes all changes to local CSV files first
- Attempts to sync to Google Sheets (if configured)
- Falls back to CSV-only if network fails
- **Never loses data** even if GSheets is unavailable

### Automated Backup Script

Create a cron job to backup data regularly:

```bash
#!/bin/bash
# backup_data.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/path/to/backup"
mkdir -p $BACKUP_DIR
cp -r /srv/shiny-server/urban-farm-dashboard/data $BACKUP_DIR/data_$DATE
```

Add to crontab:
```bash
0 0 * * * /path/to/backup_data.sh  # Daily at midnight
0 */4 * * * /path/to/backup_data.sh  # Every 4 hours
```

## Monitoring

### Application Logs

**Shiny Server**
```bash
tail -f /var/log/shiny-server/
tail -f /var/log/shiny-server/urban-farm-dashboard/
```

**Docker**
```bash
docker logs -f urban-farm-dashboard
```

### Health Check

Create a simple health check script:

```bash
#!/bin/bash
# health_check.sh
if curl -f http://localhost:3838/urban-farm-dashboard > /dev/null 2>&1; then
  echo "OK"
else
  echo "ERROR: App not responding"
  # Can trigger restart or alert here
fi
```

### Performance Monitoring

Monitor:
- CPU and memory usage
- Disk space (for data storage)
- Data file sizes
- Response times

## Security Considerations

1. **Authentication**: Consider adding authentication for production use
   - Use Shiny authentication packages
   - Implement behind reverse proxy with auth

2. **HTTPS**: Always use HTTPS in production
   - Use nginx/Apache reverse proxy
   - Enable SSL certificates (Let's Encrypt)

3. **Data Access**: Restrict file system access appropriately
   - Limit read/write permissions on data directory
   - Use different user accounts for app process

4. **Google Sheets**: Protect service account credentials
   - Never commit JSON files to version control
   - Use environment variables for secrets
   - Rotate credentials regularly

5. **Input Validation**: Already implemented
   - All user inputs validated
   - Date format checking
   - Type validation

6. **Dependencies**: Keep R packages updated
   ```r
   update.packages()  # Update all packages
   ```

7. **Firewall**: Restrict access appropriately
   - Only expose port 3838 to trusted networks
   - Use firewall rules to limit access

## Troubleshooting

### App Won't Start

**Error: "package not found"**
```r
install.packages("package_name")
```

**Error: "Port already in use"**
- Check for other Shiny instances: `lsof -i :3838`
- Kill existing process: `kill <PID>`
- Or use different port: `shiny::runApp(port = 3839)`

**Error: "Permission denied" on data directory**
```bash
chmod -R 755 /path/to/data
chown -R shiny:shiny /path/to/data
```

### Data Not Persisting

- Verify write permissions on data directory
- Check disk space: `df -h`
- Ensure CSV files are not corrupted
- Check console for error messages

### Google Sheets Not Connecting

- Verify `GSHEETS_SHEET_ID` is set correctly
- Check service account has edit access to sheet
- Verify sheet tab names match environment variables
- **App will automatically fall back to local CSV files**

### Performance Issues

- Monitor RAM usage: `free -h`
- Check if data files are too large (>100MB)
- Implement pagination for large datasets
- Use caching for frequently accessed data
- Upgrade server resources if needed

## Support

For issues or questions:
- Check [quick_start.Rmd](quick_start.Rmd) for quick reference
- Review [data_schema.md](data_schema.md) for data structure
- See [development.md](development.md) for technical details
- Check README.md for comprehensive documentation
- Review application logs for error details

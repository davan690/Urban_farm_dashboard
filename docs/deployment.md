# Urban Farm Dashboard - Deployment Guide

## Local Development

### Prerequisites
- R (>= 3.5.0)
- RStudio (recommended)
- Required packages: shiny, shinydashboard, DT, ggplot2, dplyr

### Running Locally
```r
# Install dependencies
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", "dplyr"))

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

### Steps
1. Copy application files to server:
```bash
scp -r Urban_farm_dashboard user@server:/srv/shiny-server/
```

2. Ensure proper permissions:
```bash
chmod -R 755 /srv/shiny-server/Urban_farm_dashboard
```

3. Restart Shiny Server:
```bash
sudo systemctl restart shiny-server
```

## Docker Deployment

### Dockerfile Example
```dockerfile
FROM rocker/shiny:latest

# Install required packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'dplyr'), repos='https://cloud.r-project.org/')"

# Copy app files
COPY . /srv/shiny-server/urban-farm-dashboard

# Expose port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server"]
```

### Build and Run
```bash
docker build -t urban-farm-dashboard .
docker run -d -p 3838:3838 urban-farm-dashboard
```

## Environment Variables

The app can be configured using environment variables:

- `DATA_DIR`: Directory for data files (default: ./data)
- `PORT`: Port to run the app on (default: Shiny default)

## Data Backup

### Automated Backup Script
Create a cron job to backup data regularly:

```bash
#!/bin/bash
# backup_data.sh
DATE=$(date +%Y%m%d_%H%M%S)
cp -r /path/to/app/data /path/to/backup/data_$DATE
```

Add to crontab:
```bash
0 0 * * * /path/to/backup_data.sh  # Daily at midnight
```

## Monitoring

### Application Logs
- Shiny Server logs: `/var/log/shiny-server/`
- Application logs: Check R console output

### Health Check
Create a simple health check endpoint or monitor application availability.

## Security Considerations

1. **Authentication**: Consider adding authentication for production use
2. **HTTPS**: Always use HTTPS in production
3. **Data Access**: Restrict file system access appropriately
4. **Input Validation**: Ensure all user inputs are validated (already implemented)
5. **Dependencies**: Keep R packages updated

## Troubleshooting

### App Won't Start
- Check R package dependencies are installed
- Verify data directory exists and has proper permissions
- Check Shiny Server logs for errors

### Data Not Persisting
- Verify write permissions on data directory
- Check disk space
- Ensure CSV files are not corrupted

### Performance Issues
- Consider upgrading server resources
- Optimize data loading (use caching)
- Implement pagination for large datasets

## Support

For issues or questions:
- Check README.Rmd for documentation
- Review application logs
- Contact development team

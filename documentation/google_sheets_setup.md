# Google Sheets Setup Guide

## Overview

This guide shows how to set up live collaborative data storage using Google Sheets for the Urban Farm Dashboard.

## Benefits

- 📊 **Live Data**: Changes sync automatically
- 👥 **Collaboration**: Multiple teachers edit simultaneously
- 📱 **Mobile Friendly**: Edit data on tablets/phones
- ☁️ **Cloud Backup**: Data stored in Google's infrastructure
- 🔄 **Automatic Sync**: Local CSV always backed up

## Prerequisites

- Google account (free)
- Google Cloud Project (free tier available)
- Permissions to create service accounts

## Step 1: Create Google Cloud Project

### 1.1 Create Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click project dropdown at top
3. Click "NEW PROJECT"
4. Enter name: "urban-farm-dashboard"
5. Click CREATE

### 1.2 Enable Google Sheets API

1. In console, search for "Google Sheets API"
2. Click "Google Sheets API"
3. Click "ENABLE"

### 1.3 Create Service Account

1. Go to IAM & Admin → Service Accounts
2. Click "CREATE SERVICE ACCOUNT"
3. Enter name: "farm-dashboard-account"
4. Click CREATE AND CONTINUE
5. Grant role: "Editor"
6. Click CONTINUE
7. Click CREATE KEY
8. Choose "JSON"
9. Click CREATE
10. Download JSON file — **keep this safe!**

## Step 2: Create Google Sheet

### 2.1 Create Spreadsheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Click "Create" → "Blank spreadsheet"
3. Name it: "Urban Farm Dashboard Data"

### 2.2 Create Worksheets

Create these sheets (tabs):

1. **Chickens** — Chicken inventory
2. **Hazards** — Hazard log
3. **AreaHazards** — Farm zone hazards (KVC)
4. **ToolRegistry** — Tool risk ratings (KVC)
5. **RiskSubmissions** — Student assessments (KVC)

### 2.3 Add Headers

For each sheet, add column headers (first row):

**Chickens**:
```
id | name | breed | age_months | health_status | last_check
```

**Hazards**:
```
id | type | description | severity | status | date_reported | date_resolved
```

**AreaHazards**:
```
Area | Hazard | Likelihood | Impact | Elimination | Mitigation
```

**ToolRegistry**:
```
Tool | BaseRisk | Teacher_Risk | AI_Risk | Hist_Risk | ToolControls
```

**RiskSubmissions**:
```
Tool | Vote | Coord | Comment | Timestamp
```

### 2.4 Share with Service Account

1. Click "Share" (top right)
2. Enter service account email from JSON file:
   - Look for `"client_email"` in downloaded JSON
   - Example: `farm-dashboard@urban-farm-123.iam.gserviceaccount.com`
3. Grant "Editor" access
4. Uncheck "Notify people"
5. Click SHARE

## Step 3: Configure Dashboard

### 3.1 Get Sheet ID

In Google Sheets URL:
```
https://docs.google.com/spreadsheets/d/ABC123XYZ.../edit
                                        ^^^^^^^^^^^
                                        Sheet ID
```

### 3.2 Set Environment Variables

**Option A: In app.R**
```r
Sys.setenv(GOOGLE_SHEETS_ID = "your_sheet_id_here")
Sys.setenv(GOOGLE_SHEETS_AUTH = "/path/to/service_account.json")
```

**Option B: In .Renviron** (persistent)
```
GOOGLE_SHEETS_ID=abc123xyz
GOOGLE_SHEETS_AUTH=/home/user/Urban_farm_dashboard/secrets/service_account.json
```

Then restart R for changes to take effect:
```r
readRenviron("~/.Renviron")
```

**Option C: RStudio Project**

In your `.Rproj` file:
```ini
[R]
GOOGLE_SHEETS_ID = abc123xyz
GOOGLE_SHEETS_AUTH = ./secrets/service_account.json
```

### 3.3 Store Service Account Safely

```bash
# Create secrets folder
mkdir -p Urban_farm_dashboard/secrets

# Copy service account JSON
cp ~/Downloads/service_account.json Urban_farm_dashboard/secrets/

# Add to .gitignore (IMPORTANT!)
echo "secrets/" >> .gitignore
git add .gitignore
git commit -m "Add secrets to gitignore"
```

## Step 4: Test Connection

Run this in R console:

```r
source("R/helpers.R")

# Test loading from Sheets
chickens <- load_chickens()
print(head(chickens))

# Test saving to Sheets
new_chicken <- data.frame(
  id = 1,
  name = "Test Bird",
  breed = "Rhode Island Red",
  age_months = 6,
  health_status = "Healthy",
  last_check = Sys.Date()
)
save_chickens(new_chicken)

# Verify in Google Sheets (should auto-refresh)
```

## Step 5: Deploy

### For shinyapps.io

1. Upload service account JSON to shinyapps.io:
   ```bash
   rsconnect::setContentCategory("application/json")
   ```

2. Set environment variables in shinyapps.io dashboard:
   - Click app name
   - Settings → Environment Variables
   - Add: `GOOGLE_SHEETS_ID=your_id`
   - Add: `GOOGLE_SHEETS_AUTH=/home/shinyapps/secrets/service_account.json`

3. Upload JSON file via SFTP or dashboard upload

### For Shiny Server

```bash
# Copy secrets to server
scp -r secrets/ user@server:/opt/shiny-apps/urban_farm_dashboard/

# Set permissions
sudo chown -R shiny:shiny /opt/shiny-apps/urban_farm_dashboard/secrets
```

### For Docker

Add to Dockerfile:

```dockerfile
# Copy secrets (ensure .dockerignore excludes these locally)
COPY secrets/ /app/secrets/
RUN chown -R nobody:nogroup /app/secrets
```

## Features with Sheets Enabled

### Auto-Sync

When Sheets is enabled:

1. User adds data in app
2. CSV writes immediately ✓
3. GSheets write attempted
4. On success → UI confirmation
5. On error → Graceful fallback to CSV

```r
# All data functions support this automatically
save_chickens(df)  # CSV always, GSheets if possible
```

### Live Collaboration

Multiple users can:
- Edit Google Sheet directly
- Changes sync to app on refresh
- Admin can verify data on Sheets
- No lost data (CSV backup always exists)

### Monitoring

Sheets gives you:
- ✓ See all student submissions
- ✓ Verify data integrity
- ✓ Export to analysis tools
- ✓ Share with colleagues
- ✓ Version history

## Troubleshooting

### "Authentication failed"

```r
# Re-authenticate
gargle::credentials_app_default(scopes = "https://www.googleapis.com/auth/spreadsheets")
```

### "Service account not found"

Check JSON path:
```r
Sys.getenv("GOOGLE_SHEETS_AUTH")
file.exists(Sys.getenv("GOOGLE_SHEETS_AUTH"))
```

### "Sheet not found"

Verify:
- Sheet ID is correct
- Service account has Editor access
- Sheet names match code (case-sensitive)

### "Quota exceeded"

Occurs after ~100 requests/minute. Solution:

```r
# Add delay between writes
Sys.sleep(1)
save_chickens(df)
```

### Data not syncing

Check:
1. Internet connection
2. Service account permissions
3. Sheet exists and has correct name
4. CSV file is being written (fallback works)

## Advanced: Multiple Sheets

To use separate Sheets for different purposes:

```r
# In R/helpers.R
SHEETS_DATA <- list(
  production = "abc123production",
  testing = "xyz789testing",
  backup = "def456backup"
)

# In app.R
CURRENT_SHEET <- SHEETS_DATA$production
Sys.setenv(GOOGLE_SHEETS_ID = CURRENT_SHEET)
```

## Cleanup & Reset

### Reset Sheets (clear all data)

1. In Google Sheets: Select all cells
2. Delete content (not sheets)
3. Add headers again

### Disconnect from Sheets

Remove from `.Renviron`:
```
# Comment out or delete:
# GOOGLE_SHEETS_ID=...
# GOOGLE_SHEETS_AUTH=...
```

App will continue to work using CSV only.

---

[← Back to Home](../README.md) | [Next: Deployment Guide](deployment.md)

# Data Schema Documentation

## Overview

The Urban Farm Dashboard uses CSV files for data storage, with automatic fallback to local CSVs if Google Sheets is unavailable. This document describes the schema for each data file.

## Chickens Data (`data/chickens.csv`)

Stores information about chickens in the farm inventory.

### Schema

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| id | Integer | Yes | Unique identifier | 1 |
| name | String | Yes | Chicken's name | "Henrietta" |
| breed | String | Yes | Breed type | "Rhode Island Red" |
| age_months | Integer | Yes | Age in months | 18 |
| health_status | String | Yes | Current health condition | "Healthy" |
| last_check | Date | Yes | Date of last health examination | "2026-02-01" |

### Valid Values

**health_status**:
- "Healthy"
- "Sick"
- "Recovering"
- "Under Observation"

**age_months**:
- Must be >= 0

## Hazards Data (`data/hazards.csv`)

Tracks hazards and safety issues on the farm.

### Schema

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| id | Integer | Yes | Unique identifier | 1 |
| type | String | Yes | Category of hazard | "Predator Activity" |
| description | String | Yes | Detailed description | "Fox spotted near coop" |
| severity | String | Yes | Severity level | "High" |
| status | String | Yes | Current status | "Active" |
| date_reported | Date | Yes | Date hazard was reported | "2026-02-05" |
| date_resolved | Date | No | Date hazard was resolved | "2026-02-08" or empty |

### Valid Values

**type**:
- "Animal Health"
- "Facility Structure"
- "Equipment Failure"
- "Weather Related"
- "Predator Activity"
- "Disease Outbreak"
- "Other"

**severity**:
- "Low" - Minor issue, low priority
- "Medium" - Moderate issue, should be addressed soon
- "High" - Serious issue, requires prompt attention
- "Critical" - Emergency situation, immediate action required

**status**:
- "Active" - Currently unresolved
- "Under Review" - Being investigated or planned
- "Resolved" - Issue has been addressed

## Risk Data Tables (KVC Farm Risk Module)

### Area Hazards (`data/area_hazards.csv`)

Reference table of environmental hazards by farm zone.

| Column | Type | Description |
|--------|------|-------------|
| Area | String | Farm zone (e.g., "Sheep Yards", "Chicken Coop") |
| Hazard | String | Hazard name |
| Likelihood | Integer | 1-5 scale |
| Impact | Integer | 1-5 scale |
| Elimination | String | Best practice to eliminate |
| Mitigation | String | Control measure if elimination not possible |

### Tool Registry (`data/tool_registry.csv`)

Reference table of farm tools with risk ratings.

| Column | Type | Description |
|--------|------|-------------|
| Tool | String | Tool name |
| BaseRisk | Integer | 1-5 baseline risk |
| Teacher_Risk | Integer | 1-5 teacher baseline |
| AI_Risk | Integer | 1-5 AI engine prediction |
| Hist_Risk | Integer | 1-5 historical average |
| ToolControls | String | Safety controls & competency requirements |

### Risk Submissions (`data/risk_submissions.csv`)

Live student-submitted risk assessments (read/write).

| Column | Type | Description |
|--------|------|-------------|
| Tool | String | Tool being assessed |
| Vote | Integer | Student risk rating (1-5) |
| Coord | String | Spatial landmark/coordinate |
| Comment | String | Justification & analysis |
| Timestamp | DateTime | ISO 8601 format submission time |

## Data Validation Rules

### Chickens

1. **ID**: Must be unique positive integer
2. **Name**: Cannot be empty string
3. **Breed**: Cannot be empty string
4. **Age**: Must be non-negative integer
5. **Health Status**: Must be one of valid values
6. **Last Check**: Must be valid date in YYYY-MM-DD format

### Hazards

1. **ID**: Must be unique positive integer
2. **Type**: Cannot be empty string
3. **Description**: Cannot be empty string
4. **Severity**: Must be one of: Low, Medium, High, Critical
5. **Status**: Must be one of valid values
6. **Date Reported**: Must be valid date in YYYY-MM-DD format
7. **Date Resolved**: Empty or valid date in YYYY-MM-DD format

## Data Management

### Backup Strategy

**Local CSV Fallback**: All data tables maintain local CSV backups:
- Ensure offline functionality
- Automatic save on every write
- No data loss if network drops

**GSheets Integration** (optional):
- Set `GSHEETS_SHEET_ID` environment variable
- Create corresponding sheet tabs
- Service account JSON required

### Adding Data

Data can be added through:
1. Application UI (recommended)
2. Direct CSV editing (for bulk imports)

When editing CSV files directly:
- Maintain proper CSV format
- Use correct date format (YYYY-MM-DD)
- Ensure unique IDs
- Follow validation rules

### Backup

Regular backups are recommended:

```bash
# Create backup
cp data/chickens.csv data/backups/chickens_$(date +%Y%m%d).csv
cp data/hazards.csv data/backups/hazards_$(date +%Y%m%d).csv
```

## File Locations

### Development
```
data/
├── chickens.csv
├── hazards.csv
├── area_hazards.csv
├── tool_registry.csv
└── risk_submissions.csv
```

### Production
Configure data directory via environment variables:
```r
data_dir <- Sys.getenv("DATA_DIR", default = "data")
```

## CSV Format Notes

### Character Encoding
- UTF-8 encoding recommended
- Handle special characters properly

### Line Endings
- Unix (LF) or Windows (CRLF) acceptable
- Be consistent within project

### Delimiters
- Use comma (,) as delimiter
- Escape commas in data fields with quotes

### Headers
- First row must contain column names
- Match schema exactly (case-sensitive)

## Troubleshooting

### Data not loading
- Check file exists in data/ directory
- Verify CSV format is correct
- Check for syntax errors in CSV

### Validation failures
- Ensure values match valid options
- Check date formats
- Verify required fields

### Data corruption
- Restore from backup
- Check for improper manual edits
- Verify application updates saved correctly

### Google Sheets connection errors
- Check `GSHEETS_SHEET_ID` environment variable
- Verify service account has edit access
- Check network connectivity
- App will automatically fall back to local CSV

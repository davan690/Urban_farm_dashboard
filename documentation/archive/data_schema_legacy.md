# Data Schema Documentation

## Overview

The Urban Farm Dashboard uses CSV files for data storage. This document describes the schema for each data file.

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

### Sample Data

```csv
id,name,breed,age_months,health_status,last_check
1,Henrietta,Rhode Island Red,18,Healthy,2026-02-01
2,Beatrice,Plymouth Rock,24,Healthy,2026-02-05
3,Ginger,Sussex,12,Under Observation,2026-02-07
```

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

**date_resolved**:
- Empty string if not resolved
- ISO date format (YYYY-MM-DD) when resolved

### Sample Data

```csv
id,type,description,severity,status,date_reported,date_resolved
1,Predator Activity,Fox spotted near chicken coop at dawn,High,Active,2026-02-05,
2,Facility Structure,Broken fence panel on west side,Medium,Under Review,2026-02-03,
3,Equipment Failure,Automatic feeder malfunction,Low,Resolved,2026-01-28,2026-01-29
```

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

### Migration

When updating schema:
1. Create backup of existing data
2. Update CSV files with new columns
3. Update helper functions in R/helpers.R
4. Update module UI and server logic
5. Test thoroughly

## Data Size Considerations

### Current Implementation

- Suitable for small to medium-sized farms (up to ~1000 chickens)
- CSV files load into memory
- No database required

### Scaling

For larger operations, consider:
- Database backend (SQLite, PostgreSQL)
- Pagination for large datasets
- Indexing for faster searches
- Caching strategies

## Data Privacy

### Sensitive Information

Consider data privacy when:
- Storing location information
- Adding personal notes
- Implementing multi-user features

### Best Practices

- Don't commit sensitive data to version control
- Use .gitignore for data files if needed
- Implement access controls for production
- Regular security audits

## File Locations

### Development
```
data/
├── chickens.csv
└── hazards.csv
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

## Extending the Schema

### Adding New Fields

1. Add column to CSV file
2. Update documentation
3. Update helper functions
4. Update validation rules
5. Update UI/server logic

Example for adding "notes" field to chickens:

```csv
id,name,breed,age_months,health_status,last_check,notes
1,Henrietta,Rhode Island Red,18,Healthy,2026-02-01,Very friendly
```

### Creating New Data Files

Follow same pattern:
1. Define schema
2. Create CSV in data/ directory
3. Create helper functions
4. Create/update module
5. Document schema

## Troubleshooting

### Common Issues

**Data not loading**
- Check file exists in data/ directory
- Verify CSV format is correct
- Check for syntax errors in CSV

**Validation failures**
- Ensure values match valid options
- Check date formats
- Verify required fields

**Data corruption**
- Restore from backup
- Check for improper manual edits
- Verify application updates saved correctly

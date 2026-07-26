# Data Schema Documentation

## Overview

The Urban Farm Dashboard uses CSV files for local data storage, with optional Google Sheets sync. This document describes all data tables.

## Chickens Data (`data/chickens.csv`)

Chicken inventory with health tracking.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique ID |
| name | String | Chicken name |
| breed | String | Breed (e.g., "Rhode Island Red") |
| age_months | Integer | Age in months |
| health_status | String | Healthy / Sick / Recovering / Under Observation |
| last_check | Date | YYYY-MM-DD format |

## Hazards Data (`data/hazards.csv`)

Farm hazard tracking.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique ID |
| type | String | Category (Animal Health, Weather, Equipment, etc.) |
| description | String | Hazard details |
| severity | String | Low / Medium / High / Critical |
| status | String | Active / Under Review / Resolved |
| date_reported | Date | YYYY-MM-DD format |
| date_resolved | Date | Empty if not resolved |

## KVC Risk Data

### Area Hazards (`data/area_hazards.csv`)

Reference table of farm zone hazards (18 zones × hazards).

| Column | Type | Description |
|--------|------|-------------|
| Area | String | Zone name |
| Hazard | String | Hazard name |
| Likelihood | Integer | 1-5 scale |
| Impact | Integer | 1-5 scale |
| Elimination | String | How to eliminate |
| Mitigation | String | Control measures |

**Zones**: General Farm, Sheep Yards, Chicken Coop, Orchard, Garden Beds, Stream Work, Forest, Bees

### Tool Registry (`data/tool_registry.csv`)

Farm tool risk ratings (19 tools).

| Column | Type | Description |
|--------|------|-------------|
| Tool | String | Tool name |
| BaseRisk | Integer | 1-5 baseline |
| Teacher_Risk | Integer | 1-5 teacher rating |
| AI_Risk | Integer | 1-5 AI prediction |
| Hist_Risk | Integer | 1-5 historical |
| ToolControls | String | Safety & competency requirements |

**Tools**: Chainsaw, Ladders, Drafting Gates, Secateurs, etc.

### Risk Submissions (`data/risk_submissions.csv`)

Live student-submitted assessments.

| Column | Type | Description |
|--------|------|-------------|
| Tool | String | Tool being assessed |
| Vote | Integer | 1-5 rating |
| Coord | String | Spatial landmark |
| Comment | String | Justification |
| Timestamp | DateTime | ISO 8601 submission time |

## Data Validation

### Required Fields
- Chickens: id, name, breed, age_months, health_status, last_check
- Hazards: id, type, description, severity, status, date_reported

### Valid Values
**health_status**: Healthy, Sick, Recovering, Under Observation
**severity**: Low, Medium, High, Critical
**status**: Active, Under Review, Resolved
**Likelihood/Impact**: 1–5 (integer)

## Backup & Fallback

**Local CSV Backup**: Always written first
- `data/chickens.csv`
- `data/hazards.csv`
- `data/area_hazards.csv`
- `data/tool_registry.csv`
- `data/risk_submissions.csv`

**Google Sheets** (optional): Synced after CSV write
- Never loses data if network fails
- CSV written regardless of GSheets status

## CSV Format

- **Encoding**: UTF-8
- **Line Endings**: LF or CRLF (consistent)
- **Delimiter**: Comma (,)
- **Quoted Fields**: Use quotes for fields with commas
- **Headers**: First row must match schema

### Example

```csv
id,name,breed,age_months,health_status,last_check
1,Henrietta,Rhode Island Red,18,Healthy,2026-02-01
2,Beatrice,Plymouth Rock,24,Healthy,2026-02-05
```

## Troubleshooting

**Data not loading**
- Verify `data/` folder exists
- Check CSV has correct headers
- Ensure UTF-8 encoding

**Validation failures**
- Check date format (YYYY-MM-DD)
- Verify values match valid options
- Ensure required fields present

**Data corruption**
- Restore from backup
- Verify manual edits
- Check file permissions

---

[← Back to Home](../README.md) | [Next: Development Guide](development.md)

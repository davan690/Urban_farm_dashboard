# Helper Functions for Urban Farm Dashboard
# This file contains utility functions used throughout the application

# Google Sheets integration
gsheets_enabled <- function() {
  nzchar(Sys.getenv("GSHEETS_SHEET_ID", ""))
}

get_gsheets_tabs <- function() {
  list(
    chickens         = Sys.getenv("GSHEETS_CHICKENS_TAB",        "Chickens"),
    hazards          = Sys.getenv("GSHEETS_HAZARDS_TAB",         "Hazards"),
    area_hazards     = Sys.getenv("GSHEETS_AREA_HAZARDS_TAB",    "AreaHazards"),
    tool_registry    = Sys.getenv("GSHEETS_TOOL_REGISTRY_TAB",   "ToolRegistry"),
    risk_submissions = Sys.getenv("GSHEETS_RISK_SUBMISSIONS_TAB","RiskSubmissions")
  )
}

ensure_gsheets_auth <- function() {
  if (!gsheets_enabled()) {
    return(FALSE)
  }

  if (isTRUE(getOption("urbanfarm.gsheets_authed", FALSE))) {
    return(TRUE)
  }

  options(gargle_quiet = TRUE)

  service_json <- Sys.getenv("GSHEETS_SERVICE_JSON", "")
  creds_path <- Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS", "")

  if (nzchar(service_json)) {
    # Write JSON to a temp file for gargle auth
    tmp_path <- tempfile(fileext = ".json")
    writeLines(service_json, tmp_path, useBytes = TRUE)
    googlesheets4::gs4_auth(path = tmp_path)
  } else if (nzchar(creds_path)) {
    googlesheets4::gs4_auth(path = creds_path)
  } else {
    stop("Google Sheets auth not configured. Set GSHEETS_SERVICE_JSON or GOOGLE_APPLICATION_CREDENTIALS.")
  }

  options(urbanfarm.gsheets_authed = TRUE)
  TRUE
}

ensure_chicken_columns <- function(data) {
  required <- c("id", "name", "breed", "age_months", "health_status", "last_check")
  for (col in required) {
    if (!col %in% names(data)) {
      data[[col]] <- if (col == "id") integer(0) else character(0)
    }
  }
  data[required]
}

ensure_hazard_columns <- function(data) {
  required <- c("id", "type", "description", "severity", "status", "date_reported", "date_resolved")
  for (col in required) {
    if (!col %in% names(data)) {
      data[[col]] <- if (col == "id") integer(0) else character(0)
    }
  }
  data[required]
}

#' Get current chicken count
#' @return Integer count of total chickens
chicken_count <- function() {
  # Load chicken data
  chickens <- load_chicken_data()
  return(nrow(chickens))
}

#' Get active hazard count
#' @return Integer count of active hazards
hazard_count <- function() {
  # Load hazard data
  hazards <- load_hazard_data()
  active_hazards <- hazards[hazards$status == "Active", ]
  return(nrow(active_hazards))
}

#' Load chicken data from CSV
#' @return Data frame with chicken information
load_chicken_data <- function() {
  if (gsheets_enabled()) {
    ensure_gsheets_auth()
    tabs <- get_gsheets_tabs()
    sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
    data <- googlesheets4::read_sheet(sheet_id, sheet = tabs$chickens, col_types = "cccccc")
    data <- as.data.frame(data, stringsAsFactors = FALSE)
    data$id <- suppressWarnings(as.integer(data$id))
    data$age_months <- suppressWarnings(as.integer(data$age_months))
    return(ensure_chicken_columns(data))
  }

  file_path <- "data/chickens.csv"
  if (file.exists(file_path)) {
    return(read.csv(file_path, stringsAsFactors = FALSE))
  }

  # Return empty data if file doesn't exist
  data <- data.frame(
    id = integer(0),
    name = character(0),
    breed = character(0),
    age_months = integer(0),
    health_status = character(0),
    last_check = character(0),
    stringsAsFactors = FALSE
  )
  data
}

#' Load hazard data from CSV
#' @return Data frame with hazard information
load_hazard_data <- function() {
  if (gsheets_enabled()) {
    ensure_gsheets_auth()
    tabs <- get_gsheets_tabs()
    sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
    data <- googlesheets4::read_sheet(sheet_id, sheet = tabs$hazards, col_types = "ccccccc")
    data <- as.data.frame(data, stringsAsFactors = FALSE)
    data$id <- suppressWarnings(as.integer(data$id))
    return(ensure_hazard_columns(data))
  }

  file_path <- "data/hazards.csv"
  if (file.exists(file_path)) {
    return(read.csv(file_path, stringsAsFactors = FALSE))
  }

  # Return empty data if file doesn't exist
  data <- data.frame(
    id = integer(0),
    type = character(0),
    description = character(0),
    severity = character(0),
    status = character(0),
    date_reported = character(0),
    date_resolved = character(0),
    stringsAsFactors = FALSE
  )
  data
}

#' Save chicken data to CSV
#' @param data Data frame with chicken information
save_chicken_data <- function(data) {
  if (gsheets_enabled()) {
    ensure_gsheets_auth()
    tabs <- get_gsheets_tabs()
    sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
    googlesheets4::write_sheet(data, ss = sheet_id, sheet = tabs$chickens)
    return(invisible(TRUE))
  }

  write.csv(data, "data/chickens.csv", row.names = FALSE)
  invisible(TRUE)
}

#' Save hazard data to CSV
#' @param data Data frame with hazard information
save_hazard_data <- function(data) {
  if (gsheets_enabled()) {
    ensure_gsheets_auth()
    tabs <- get_gsheets_tabs()
    sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
    googlesheets4::write_sheet(data, ss = sheet_id, sheet = tabs$hazards)
    return(invisible(TRUE))
  }

  write.csv(data, "data/hazards.csv", row.names = FALSE)
  invisible(TRUE)
}

# ---------------------------------------------------------------------------
# Risk Dashboard Data Helpers
# ---------------------------------------------------------------------------

ensure_area_hazard_columns <- function(data) {
  required <- c("Area", "Hazard", "Likelihood", "Impact", "Elimination", "Mitigation")
  for (col in required) {
    if (!col %in% names(data)) data[[col]] <- character(0)
  }
  data[required]
}

ensure_tool_registry_columns <- function(data) {
  required <- c("Tool", "BaseRisk", "Teacher_Risk", "AI_Risk", "Hist_Risk", "ToolControls")
  for (col in required) {
    if (!col %in% names(data)) data[[col]] <- if (col == "Tool" || col == "ToolControls") character(0) else integer(0)
  }
  data[required]
}

ensure_risk_submission_columns <- function(data) {
  required <- c("Tool", "Vote", "Coord", "Comment", "Timestamp")
  for (col in required) {
    if (!col %in% names(data)) data[[col]] <- character(0)
  }
  data[required]
}

#' Load area hazard reference data.
#' Tries Google Sheets first; falls back to data/area_hazards.csv.
load_area_hazards <- function() {
  if (gsheets_enabled()) {
    result <- tryCatch({
      ensure_gsheets_auth()
      tabs <- get_gsheets_tabs()
      sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
      data <- googlesheets4::read_sheet(sheet_id, sheet = tabs$area_hazards,
                                        col_types = "ccddcc")
      data <- as.data.frame(data, stringsAsFactors = FALSE)
      data$Likelihood <- suppressWarnings(as.integer(data$Likelihood))
      data$Impact     <- suppressWarnings(as.integer(data$Impact))
      ensure_area_hazard_columns(data)
    }, error = function(e) {
      message("[offline] area_hazards: ", conditionMessage(e))
      NULL
    })
    if (!is.null(result)) return(result)
  }

  file_path <- "data/area_hazards.csv"
  if (file.exists(file_path)) {
    data <- read.csv(file_path, stringsAsFactors = FALSE)
    data$Likelihood <- suppressWarnings(as.integer(data$Likelihood))
    data$Impact     <- suppressWarnings(as.integer(data$Impact))
    return(ensure_area_hazard_columns(data))
  }

  ensure_area_hazard_columns(data.frame(
    Area = character(0), Hazard = character(0),
    Likelihood = integer(0), Impact = integer(0),
    Elimination = character(0), Mitigation = character(0),
    stringsAsFactors = FALSE
  ))
}

#' Load tool registry reference data.
#' Tries Google Sheets first; falls back to data/tool_registry.csv.
load_tool_registry <- function() {
  if (gsheets_enabled()) {
    result <- tryCatch({
      ensure_gsheets_auth()
      tabs <- get_gsheets_tabs()
      sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
      data <- googlesheets4::read_sheet(sheet_id, sheet = tabs$tool_registry,
                                        col_types = "cddddc")
      data <- as.data.frame(data, stringsAsFactors = FALSE)
      for (col in c("BaseRisk", "Teacher_Risk", "AI_Risk", "Hist_Risk")) {
        data[[col]] <- suppressWarnings(as.integer(data[[col]]))
      }
      ensure_tool_registry_columns(data)
    }, error = function(e) {
      message("[offline] tool_registry: ", conditionMessage(e))
      NULL
    })
    if (!is.null(result)) return(result)
  }

  file_path <- "data/tool_registry.csv"
  if (file.exists(file_path)) {
    data <- read.csv(file_path, stringsAsFactors = FALSE)
    for (col in c("BaseRisk", "Teacher_Risk", "AI_Risk", "Hist_Risk")) {
      data[[col]] <- suppressWarnings(as.integer(data[[col]]))
    }
    return(ensure_tool_registry_columns(data))
  }

  ensure_tool_registry_columns(data.frame(
    Tool = character(0), BaseRisk = integer(0), Teacher_Risk = integer(0),
    AI_Risk = integer(0), Hist_Risk = integer(0), ToolControls = character(0),
    stringsAsFactors = FALSE
  ))
}

#' Load crowdsourced risk submissions.
#' Tries Google Sheets first; falls back to data/risk_submissions.csv.
load_risk_submissions <- function() {
  if (gsheets_enabled()) {
    result <- tryCatch({
      ensure_gsheets_auth()
      tabs <- get_gsheets_tabs()
      sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
      data <- googlesheets4::read_sheet(sheet_id, sheet = tabs$risk_submissions,
                                        col_types = "cdccc")
      data <- as.data.frame(data, stringsAsFactors = FALSE)
      data$Vote <- suppressWarnings(as.integer(data$Vote))
      ensure_risk_submission_columns(data)
    }, error = function(e) {
      message("[offline] risk_submissions: ", conditionMessage(e))
      NULL
    })
    if (!is.null(result)) return(result)
  }

  file_path <- "data/risk_submissions.csv"
  if (file.exists(file_path)) {
    data <- read.csv(file_path, stringsAsFactors = FALSE)
    data$Vote <- suppressWarnings(as.integer(data$Vote))
    return(ensure_risk_submission_columns(data))
  }

  ensure_risk_submission_columns(data.frame(
    Tool = character(0), Vote = integer(0), Coord = character(0),
    Comment = character(0), Timestamp = character(0),
    stringsAsFactors = FALSE
  ))
}

#' Save crowdsourced risk submissions.
#' Writes to Google Sheets if configured; always writes local CSV backup.
#' @param data Data frame with submission data
save_risk_submissions <- function(data) {
  # Always write local CSV as backup regardless of GSheets status
  write.csv(data, "data/risk_submissions.csv", row.names = FALSE)

  if (gsheets_enabled()) {
    tryCatch({
      ensure_gsheets_auth()
      tabs <- get_gsheets_tabs()
      sheet_id <- Sys.getenv("GSHEETS_SHEET_ID")
      googlesheets4::write_sheet(data, ss = sheet_id, sheet = tabs$risk_submissions)
    }, error = function(e) {
      message("[offline] Could not save risk_submissions to Google Sheets: ", conditionMessage(e))
    })
  }

  invisible(TRUE)
}

#' Format date for display
#' @param date Date object or string
#' @return Formatted date string
format_date <- function(date) {
  if (is.na(date) || date == "") {
    return("N/A")
  }
  return(format(as.Date(date), "%Y-%m-%d"))
}

#' Validate chicken data entry
#' @param name Chicken name
#' @param breed Chicken breed
#' @param age Age in months
#' @return List with valid flag and message
validate_chicken_entry <- function(name, breed, age) {
  if (name == "" || breed == "") {
    return(list(valid = FALSE, message = "Name and breed are required"))
  }
  if (!is.numeric(age) || age < 0) {
    return(list(valid = FALSE, message = "Age must be a positive number"))
  }
  return(list(valid = TRUE, message = "Valid entry"))
}

#' Validate hazard data entry
#' @param type Hazard type
#' @param description Hazard description
#' @param severity Severity level
#' @return List with valid flag and message
validate_hazard_entry <- function(type, description, severity) {
  if (type == "" || description == "") {
    return(list(valid = FALSE, message = "Type and description are required"))
  }
  if (!severity %in% c("Low", "Medium", "High", "Critical")) {
    return(list(valid = FALSE, message = "Invalid severity level"))
  }
  return(list(valid = TRUE, message = "Valid entry"))
}

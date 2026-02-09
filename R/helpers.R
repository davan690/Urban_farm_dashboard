# Helper Functions for Urban Farm Dashboard
# This file contains utility functions used throughout the application

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
  file_path <- "data/chickens.csv"
  if (file.exists(file_path)) {
    return(read.csv(file_path, stringsAsFactors = FALSE))
  } else {
    # Return sample data if file doesn't exist
    return(data.frame(
      id = integer(0),
      name = character(0),
      breed = character(0),
      age_months = integer(0),
      health_status = character(0),
      last_check = character(0),
      stringsAsFactors = FALSE
    ))
  }
}

#' Load hazard data from CSV
#' @return Data frame with hazard information
load_hazard_data <- function() {
  file_path <- "data/hazards.csv"
  if (file.exists(file_path)) {
    return(read.csv(file_path, stringsAsFactors = FALSE))
  } else {
    # Return sample data if file doesn't exist
    return(data.frame(
      id = integer(0),
      type = character(0),
      description = character(0),
      severity = character(0),
      status = character(0),
      date_reported = character(0),
      date_resolved = character(0),
      stringsAsFactors = FALSE
    ))
  }
}

#' Save chicken data to CSV
#' @param data Data frame with chicken information
save_chicken_data <- function(data) {
  write.csv(data, "data/chickens.csv", row.names = FALSE)
}

#' Save hazard data to CSV
#' @param data Data frame with hazard information
save_hazard_data <- function(data) {
  write.csv(data, "data/hazards.csv", row.names = FALSE)
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

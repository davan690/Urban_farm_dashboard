# Hazards Module
# UI and Server functions for managing farm hazards

#' Hazards Module UI
#' @param id Module namespace ID
#' @return Shiny UI elements
hazardsUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Hazard Management"),
    
    # Action buttons
    fluidRow(
      box(
        width = 12,
        actionButton(ns("add_hazard"), "Report New Hazard", icon = icon("plus"), 
                     class = "btn-warning"),
        actionButton(ns("refresh"), "Refresh Data", icon = icon("refresh"))
      )
    ),
    
    # Filter controls
    fluidRow(
      box(
        title = "Filters",
        width = 12,
        status = "warning",
        selectInput(ns("status_filter"), "Filter by Status:", 
                    choices = c("All", "Active", "Resolved", "Under Review"),
                    selected = "All"),
        selectInput(ns("severity_filter"), "Filter by Severity:", 
                    choices = c("All", "Low", "Medium", "High", "Critical"),
                    selected = "All")
      )
    ),
    
    # Hazard table
    fluidRow(
      box(
        title = "Hazard Log",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        DTOutput(ns("hazard_table"))
      )
    ),
    
    # Statistics
    fluidRow(
      box(
        title = "Hazard Severity Distribution",
        width = 6,
        status = "info",
        solidHeader = TRUE,
        plotOutput(ns("severity_plot"))
      ),
      box(
        title = "Hazard Status Overview",
        width = 6,
        status = "info",
        solidHeader = TRUE,
        plotOutput(ns("status_plot"))
      )
    )
  )
}

#' Hazards Module Server
#' @param id Module namespace ID
hazardsServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive value to store hazard data
    hazard_data <- reactiveVal(load_hazard_data())
    
    # Refresh data
    observeEvent(input$refresh, {
      hazard_data(load_hazard_data())
      showNotification("Data refreshed", type = "message")
    })
    
    # Add new hazard modal
    observeEvent(input$add_hazard, {
      showModal(modalDialog(
        title = "Report New Hazard",
        selectInput(ns("new_type"), "Hazard Type:", 
                    choices = c(
                      "Animal Health",
                      "Facility Structure",
                      "Equipment Failure",
                      "Weather Related",
                      "Predator Activity",
                      "Disease Outbreak",
                      "Other"
                    )),
        textAreaInput(ns("new_description"), "Description:", 
                      placeholder = "Provide detailed description of the hazard...",
                      rows = 4),
        selectInput(ns("new_severity"), "Severity:", 
                    choices = c("Low", "Medium", "High", "Critical")),
        selectInput(ns("new_status"), "Status:", 
                    choices = c("Active", "Under Review", "Resolved"),
                    selected = "Active"),
        dateInput(ns("new_date"), "Date Reported:", value = Sys.Date()),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_add"), "Report Hazard", class = "btn-warning")
        )
      ))
    })
    
    # Confirm adding hazard
    observeEvent(input$confirm_add, {
      # Validate input
      validation <- validate_hazard_entry(
        input$new_type, 
        input$new_description, 
        input$new_severity
      )
      
      if (!validation$valid) {
        showNotification(validation$message, type = "error")
        return()
      }
      
      # Get current data
      current_data <- hazard_data()
      
      # Generate new ID
      new_id <- if (nrow(current_data) == 0) 1 else max(current_data$id) + 1
      
      # Create new row
      new_hazard <- data.frame(
        id = new_id,
        type = input$new_type,
        description = input$new_description,
        severity = input$new_severity,
        status = input$new_status,
        date_reported = as.character(input$new_date),
        date_resolved = "",
        stringsAsFactors = FALSE
      )
      
      # Add to data
      updated_data <- rbind(current_data, new_hazard)
      save_hazard_data(updated_data)
      hazard_data(updated_data)
      
      # Close modal and show notification
      removeModal()
      showNotification("Hazard reported successfully!", type = "warning")
    })
    
    # Filtered hazard data
    filtered_hazards <- reactive({
      data <- hazard_data()
      
      # Filter by status
      if (input$status_filter != "All") {
        data <- data[data$status == input$status_filter, ]
      }
      
      # Filter by severity
      if (input$severity_filter != "All") {
        data <- data[data$severity == input$severity_filter, ]
      }
      
      return(data)
    })
    
    # Render hazard table
    output$hazard_table <- renderDT({
      datatable(
        filtered_hazards(),
        options = list(
          pageLength = 10,
          searching = TRUE,
          ordering = TRUE
        ),
        rownames = FALSE
      )
    })
    
    # Render severity distribution plot
    output$severity_plot <- renderPlot({
      data <- hazard_data()
      if (nrow(data) == 0) {
        plot.new()
        text(0.5, 0.5, "No data available", cex = 1.5)
        return()
      }
      
      # Define colors for severity levels
      severity_colors <- c(
        "Low" = "#28a745",
        "Medium" = "#ffc107",
        "High" = "#fd7e14",
        "Critical" = "#dc3545"
      )
      
      ggplot(data, aes(x = severity, fill = severity)) +
        geom_bar() +
        scale_fill_manual(values = severity_colors) +
        theme_minimal() +
        labs(
          title = "Hazards by Severity",
          x = "Severity Level",
          y = "Count"
        ) +
        theme(legend.position = "none")
    })
    
    # Render status overview plot
    output$status_plot <- renderPlot({
      data <- hazard_data()
      if (nrow(data) == 0) {
        plot.new()
        text(0.5, 0.5, "No data available", cex = 1.5)
        return()
      }
      
      ggplot(data, aes(x = status, fill = status)) +
        geom_bar() +
        theme_minimal() +
        labs(
          title = "Hazards by Status",
          x = "Status",
          y = "Count"
        ) +
        theme(legend.position = "none")
    })
  })
}

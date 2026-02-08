# Chickens Module
# UI and Server functions for managing chicken inventory and health

#' Chickens Module UI
#' @param id Module namespace ID
#' @return Shiny UI elements
chickensUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Chicken Management"),
    
    # Action buttons
    fluidRow(
      box(
        width = 12,
        actionButton(ns("add_chicken"), "Add New Chicken", icon = icon("plus"), 
                     class = "btn-success"),
        actionButton(ns("refresh"), "Refresh Data", icon = icon("refresh"))
      )
    ),
    
    # Chicken inventory table
    fluidRow(
      box(
        title = "Chicken Inventory",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        DTOutput(ns("chicken_table"))
      )
    ),
    
    # Statistics
    fluidRow(
      box(
        title = "Health Status Distribution",
        width = 6,
        status = "info",
        solidHeader = TRUE,
        plotOutput(ns("health_plot"))
      ),
      box(
        title = "Breed Distribution",
        width = 6,
        status = "info",
        solidHeader = TRUE,
        plotOutput(ns("breed_plot"))
      )
    )
  )
}

#' Chickens Module Server
#' @param id Module namespace ID
chickensServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive value to store chicken data
    chicken_data <- reactiveVal(load_chicken_data())
    
    # Refresh data
    observeEvent(input$refresh, {
      chicken_data(load_chicken_data())
      showNotification("Data refreshed", type = "message")
    })
    
    # Add new chicken modal
    observeEvent(input$add_chicken, {
      showModal(modalDialog(
        title = "Add New Chicken",
        textInput(ns("new_name"), "Name:", placeholder = "e.g., Henrietta"),
        textInput(ns("new_breed"), "Breed:", placeholder = "e.g., Rhode Island Red"),
        numericInput(ns("new_age"), "Age (months):", value = 0, min = 0),
        selectInput(ns("new_health"), "Health Status:", 
                    choices = c("Healthy", "Sick", "Recovering", "Under Observation")),
        dateInput(ns("new_date"), "Last Health Check:", value = Sys.Date()),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_add"), "Add Chicken", class = "btn-success")
        )
      ))
    })
    
    # Confirm adding chicken
    observeEvent(input$confirm_add, {
      # Validate input
      validation <- validate_chicken_entry(
        input$new_name, 
        input$new_breed, 
        input$new_age
      )
      
      if (!validation$valid) {
        showNotification(validation$message, type = "error")
        return()
      }
      
      # Get current data
      current_data <- chicken_data()
      
      # Generate new ID
      new_id <- if (nrow(current_data) == 0) 1 else max(current_data$id) + 1
      
      # Create new row
      new_chicken <- data.frame(
        id = new_id,
        name = input$new_name,
        breed = input$new_breed,
        age_months = input$new_age,
        health_status = input$new_health,
        last_check = as.character(input$new_date),
        stringsAsFactors = FALSE
      )
      
      # Add to data
      updated_data <- rbind(current_data, new_chicken)
      save_chicken_data(updated_data)
      chicken_data(updated_data)
      
      # Close modal and show notification
      removeModal()
      showNotification("Chicken added successfully!", type = "message")
    })
    
    # Render chicken table
    output$chicken_table <- renderDT({
      datatable(
        chicken_data(),
        options = list(
          pageLength = 10,
          searching = TRUE,
          ordering = TRUE
        ),
        rownames = FALSE
      )
    })
    
    # Render health status plot
    output$health_plot <- renderPlot({
      data <- chicken_data()
      if (nrow(data) == 0) {
        plot.new()
        text(0.5, 0.5, "No data available", cex = 1.5)
        return()
      }
      
      ggplot(data, aes(x = health_status, fill = health_status)) +
        geom_bar() +
        theme_minimal() +
        labs(
          title = "Chickens by Health Status",
          x = "Health Status",
          y = "Count"
        ) +
        theme(legend.position = "none")
    })
    
    # Render breed distribution plot
    output$breed_plot <- renderPlot({
      data <- chicken_data()
      if (nrow(data) == 0) {
        plot.new()
        text(0.5, 0.5, "No data available", cex = 1.5)
        return()
      }
      
      ggplot(data, aes(x = breed, fill = breed)) +
        geom_bar() +
        theme_minimal() +
        labs(
          title = "Chickens by Breed",
          x = "Breed",
          y = "Count"
        ) +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "none"
        )
    })
  })
}

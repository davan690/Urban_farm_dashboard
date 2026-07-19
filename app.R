# Urban Farm Dashboard - RShiny Application
# Main application file for farm task management
# Focus: Chickens and Hazards

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)

# Source helper functions
source("R/helpers.R", local = TRUE)

# Source modules
source("modules/chickens_module.R",   local = TRUE)
source("modules/hazards_module.R",    local = TRUE)
source("modules/farm_risk_module.R",  local = TRUE)

# Define UI
ui <- dashboardPage(
  skin = "green",
  
  # Header
  dashboardHeader(title = "Urban Farm Dashboard"),
  
  # Sidebar
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Chickens", tabName = "chickens", icon = icon("drumstick-bite")),
      menuItem("Hazards", tabName = "hazards", icon = icon("exclamation-triangle")),
      menuItem("Farm Risk", tabName = "farm_risk", icon = icon("shield-alt")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  # Body
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    tabItems(
      # Dashboard tab
      tabItem(
        tabName = "dashboard",
        h2("Farm Task Management Overview"),
        fluidRow(
          valueBoxOutput("total_chickens"),
          valueBoxOutput("active_hazards"),
          valueBoxOutput("tasks_today")
        ),
        fluidRow(
          box(
            title = "Recent Activities",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            "Welcome to the Urban Farm Dashboard. Use the menu to navigate to specific sections."
          )
        )
      ),
      
      # Chickens tab
      tabItem(
        tabName = "chickens",
        chickensUI("chickens")
      ),
      
      # Hazards tab
      tabItem(
        tabName = "hazards",
        hazardsUI("hazards")
      ),
      
      # Farm Risk tab
      tabItem(
        tabName = "farm_risk",
        farmRiskUI("farm_risk")
      ),

      # About tab
      tabItem(
        tabName = "about",
        h2("About Urban Farm Dashboard"),
        box(
          width = 12,
          h3("Purpose"),
          p("This dashboard helps manage urban farm tasks with a focus on:"),
          tags$ul(
            tags$li("Chicken management and health tracking"),
            tags$li("Hazard identification and mitigation"),
            tags$li("Task scheduling and completion")
          ),
          h3("Features"),
          tags$ul(
            tags$li("Real-time chicken inventory and health monitoring"),
            tags$li("Hazard logging and tracking system"),
            tags$li("Task management and reporting")
          ),
          h3("Documentation"),
          p("For detailed documentation, please refer to the README.Rmd file in the project directory.")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Dashboard value boxes
  output$total_chickens <- renderValueBox({
    valueBox(
      value = chicken_count(),
      subtitle = "Total Chickens",
      icon = icon("drumstick-bite"),
      color = "yellow"
    )
  })
  
  output$active_hazards <- renderValueBox({
    valueBox(
      value = hazard_count(),
      subtitle = "Active Hazards",
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
  
  output$tasks_today <- renderValueBox({
    valueBox(
      value = "0",
      subtitle = "Tasks Today",
      icon = icon("tasks"),
      color = "blue"
    )
  })
  
  # Call module servers
  chickensServer("chickens")
  hazardsServer("hazards")
  farmRiskServer("farm_risk")
}

# Run the application
shinyApp(ui = ui, server = server)

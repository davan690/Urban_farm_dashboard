# Farm Risk Module
# KVC Farm Risk Matrix & Crowdsourced Dashboard
# Ported from kvc_farm_risk_matrix_crowdsourced_dashboard.html into Shiny
#
# Data sources (Google Sheets preferred; CSV fallback for offline use):
#   - AreaHazards      tab / data/area_hazards.csv
#   - ToolRegistry     tab / data/tool_registry.csv
#   - RiskSubmissions  tab / data/risk_submissions.csv  (read-write; CSV always written as backup)
#
# Tabs:
#   1. Job Risk Calculator  – select area + tools → risk scores + hazard table + tool controls
#   2. Compare Risk Profiles – bar chart & table comparing Teacher / AI / Historical / Live data
#   3. Log Assessment        – crowdsourced submission form + live data feed

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

farmRiskUI <- function(id) {
  ns <- NS(id)

  tagList(
    h2(
      icon("shield-alt"), " Farm Risk & Safety Dashboard",
      style = "color: #065f46; font-weight: bold; margin-bottom: 4px;"
    ),
    p(
      "KVC Year 9/10 Farm Studies — Risk Matrix, Tool Controls & Crowdsourced Assessments",
      class = "text-muted", style = "margin-bottom: 16px;"
    ),

    tabsetPanel(
      id = ns("risk_tabs"),
      type = "tabs",

      # ------------------------------------------------------------------
      # TAB 1: JOB RISK CALCULATOR
      # ------------------------------------------------------------------
      tabPanel(
        title = tagList(icon("calculator"), " Job Risk Calculator"),
        value = "calculator",
        br(),
        fluidRow(
          # ---- LEFT: configuration sidebar ----
          box(
            title = tagList(icon("sliders-h"), " Configuration"),
            width = 4,
            status = "success",
            solidHeader = TRUE,

            selectInput(
              ns("select_area"), "Step 1 — Farm Area / Zone:",
              choices = NULL
            ),

            hr(),

            tags$strong("Step 2 — Assign Tools"),
            tags$p(
              "Select all tools needed for the scheduled job.",
              style = "font-size: 12px; color: #6c757d; margin: 4px 0 8px 0;"
            ),
            div(
              style = "max-height: 320px; overflow-y: auto;",
              uiOutput(ns("tool_checklist"))
            )
          ),

          # ---- RIGHT: results ----
          box(
            title = tagList(icon("chart-bar"), " Risk Assessment Results"),
            width = 8,
            status = "primary",
            solidHeader = TRUE,

            fluidRow(
              valueBoxOutput(ns("area_risk_box"),  width = 4),
              valueBoxOutput(ns("tool_risk_box"),  width = 4),
              valueBoxOutput(ns("job_status_box"), width = 4)
            ),

            hr(),

            tags$h4(tagList(icon("map-pin"), " Active Environmental Hazards")),
            DTOutput(ns("hazards_table")),

            hr(),

            tags$h4(tagList(icon("clipboard-check"), " Tool Operational Controls")),
            uiOutput(ns("tool_controls"))
          )
        )
      ),

      # ------------------------------------------------------------------
      # TAB 2: COMPARE RISK PROFILES
      # ------------------------------------------------------------------
      tabPanel(
        title = tagList(icon("balance-scale"), " Compare Risk Profiles"),
        value = "compare",
        br(),
        fluidRow(
          # ---- LEFT: tool selector + legend ----
          box(
            title = tagList(icon("wrench"), " Tool Diagnostic Pane"),
            width = 4,
            status = "success",
            solidHeader = TRUE,

            selectInput(
              ns("compare_tool"), "Select Tool to Compare:",
              choices = NULL
            ),

            hr(),

            wellPanel(
              style = "background-color: #f0fdf4; border: 1px solid #bbf7d0;",
              tags$h5(icon("info-circle"), " Profile Key"),
              tags$ul(
                style = "font-size: 12px; padding-left: 16px;",
                tags$li(tags$strong("Teacher Baseline:"),
                        " Statutory benchmark from NZ health & safety standards."),
                tags$li(tags$strong("AI Engine:"),
                        " Risk estimates based on industry agricultural models."),
                tags$li(tags$strong("Last Semester:"),
                        " Historical student consensus (42 portfolio entries)."),
                tags$li(tags$strong("Class Crowdsourced:"),
                        " Live inputs submitted in the current session.")
              )
            )
          ),

          # ---- RIGHT: chart + variance table ----
          box(
            title = tagList(icon("chart-bar"), " Multi-Profile Risk Alignment"),
            width = 8,
            status = "primary",
            solidHeader = TRUE,

            plotOutput(ns("comparison_chart"), height = "280px"),

            hr(),

            tags$h4("Statistical Variance Details"),
            DTOutput(ns("variance_table"))
          )
        )
      ),

      # ------------------------------------------------------------------
      # TAB 3: LIVE CROWDSOURCED ENTRY
      # ------------------------------------------------------------------
      tabPanel(
        title = tagList(icon("upload"), " Log Assessment",
                        tags$span(
                          "LIVE",
                          style = paste0(
                            "background:#f59e0b; color:#1c1917; font-size:10px;",
                            "font-weight:bold; border-radius:4px; padding:2px 5px;",
                            "margin-left:6px; vertical-align:middle;"
                          )
                        )),
        value = "submit",
        br(),
        fluidRow(
          # ---- LEFT: submission form ----
          box(
            title = tagList(icon("edit"), " File Your Field Assessment"),
            width = 5,
            status = "warning",
            solidHeader = TRUE,

            selectInput(
              ns("input_tool"), "Tool Assessed:",
              choices = NULL
            ),

            sliderInput(
              ns("input_risk"), "Evaluated Risk Level (1–5):",
              min = 1, max = 5, value = 3, step = 1, ticks = TRUE
            ),
            tags$p(
              "1 = Low Risk (Easy Spade)  →  5 = Critical Risk (Chainsaw)",
              style = "font-size: 11px; color: #6c757d; margin-top: -8px;"
            ),

            textInput(
              ns("input_coord"),
              "Spatial Landmark / Coordinate Context:",
              placeholder = "e.g., KVC-Paddock-3, Stream Bend A"
            ),

            textAreaInput(
              ns("input_comment"),
              "Justification & Analysis Remarks:",
              placeholder = paste0(
                "Explain your risk rating based on elimination/mitigation criteria. ",
                "What hazards are present? What controls apply?"
              ),
              rows = 4
            ),

            actionButton(
              ns("submit_assessment"),
              label = tagList(icon("upload"), " Submit To Master Registry"),
              class = "btn-warning btn-block"
            )
          ),

          # ---- RIGHT: live feed ----
          box(
            title = tagList(icon("rss"), " Live Crowdsourced Datastream"),
            width = 7,
            status = "primary",
            solidHeader = TRUE,

            fluidRow(
              column(8,
                tags$p(
                  "Real-time uploads logged during field assessments.",
                  style = "font-size: 12px; color: #6c757d; margin: 0;"
                )
              ),
              column(4,
                div(
                  textOutput(ns("vote_count")),
                  style = "text-align:right; font-weight:bold; color:#065f46;"
                )
              )
            ),

            br(),

            DTOutput(ns("live_feed_table"))
          )
        )
      )
    )
  )
}

# ---------------------------------------------------------------------------
# SERVER
# ---------------------------------------------------------------------------

farmRiskServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # -----------------------------------------------------------------------
    # REACTIVE DATA SOURCES
    # Reference tables loaded once per session (teachers edit via GSheets)
    # -----------------------------------------------------------------------

    area_hazards <- reactive({
      load_area_hazards()
    })

    tool_registry <- reactive({
      load_tool_registry()
    })

    # Submissions are mutable — use reactiveVal so UI updates on write
    submissions <- reactiveVal(load_risk_submissions())

    # -----------------------------------------------------------------------
    # POPULATE DROPDOWNS ON LOAD
    # -----------------------------------------------------------------------

    observe({
      hazards <- area_hazards()
      areas   <- unique(hazards$Area)
      updateSelectInput(session, "select_area", choices = areas)
    })

    observe({
      tools      <- tool_registry()
      tool_names <- tools$Tool
      updateSelectInput(session, "compare_tool", choices = tool_names)
      updateSelectInput(session, "input_tool",   choices = tool_names)
    })

    # -----------------------------------------------------------------------
    # TOOL CHECKLIST (dynamic checkbox group)
    # -----------------------------------------------------------------------

    output$tool_checklist <- renderUI({
      tools <- tool_registry()
      checkboxGroupInput(
        ns("selected_tools"),
        label = NULL,
        choices = setNames(tools$Tool, tools$Tool)
      )
    })

    # -----------------------------------------------------------------------
    # TAB 1 HELPERS
    # -----------------------------------------------------------------------

    active_hazards <- reactive({
      req(input$select_area)
      h <- area_hazards()
      h[h$Area == input$select_area, ]
    })

    max_area_score <- reactive({
      h <- active_hazards()
      if (nrow(h) == 0) return(0L)
      max(h$Likelihood * h$Impact)
    })

    active_tools <- reactive({
      tools <- tool_registry()
      selected <- input$selected_tools
      if (is.null(selected) || length(selected) == 0) return(tools[0L, ])
      tools[tools$Tool %in% selected, ]
    })

    max_tool_class <- reactive({
      td <- active_tools()
      if (nrow(td) == 0) return(0L)
      max(td$BaseRisk)
    })

    # -----------------------------------------------------------------------
    # TAB 1 — VALUE BOXES
    # -----------------------------------------------------------------------

    output$area_risk_box <- renderValueBox({
      score  <- max_area_score()
      color  <- if (score >= 12) "red" else if (score >= 6) "yellow" else "green"
      status <- if (score >= 12) "High Risk Zone"
                else if (score >= 6) "Moderate Hazard"
                else "Healthy Baseline"
      valueBox(score, paste("Area Max Score —", status),
               icon = icon("map"), color = color)
    })

    output$tool_risk_box <- renderValueBox({
      level  <- max_tool_class()
      color  <- if (level == 5) "red" else if (level >= 3) "yellow" else "green"
      label  <- if (level == 0) "No Tool Selected"
                else if (level == 5) "Teacher-Only Operation"
                else if (level >= 3) "Competency Sign-off Required"
                else "Standard Controls"
      valueBox(
        if (level == 0) "None" else paste0("Class ", level),
        paste("Highest Tool —", label),
        icon = icon("wrench"), color = color
      )
    })

    output$job_status_box <- renderValueBox({
      combined <- max_area_score() + (max_tool_class() * 2L)
      if (max_tool_class() == 5 || combined >= 20) {
        valueBox("CRITICAL", "Teacher Only — Students Observe",
                 icon = icon("ban"), color = "red")
      } else if (max_tool_class() >= 3 || combined >= 12) {
        valueBox("HIGH", "Strict Supervision Required",
                 icon = icon("exclamation-triangle"), color = "yellow")
      } else {
        valueBox("STANDARD", "Proceed with Basic PPE",
                 icon = icon("check-circle"), color = "green")
      }
    })

    # -----------------------------------------------------------------------
    # TAB 1 — HAZARDS TABLE
    # -----------------------------------------------------------------------

    output$hazards_table <- renderDT({
      h <- active_hazards()

      if (nrow(h) == 0) {
        return(datatable(
          data.frame(Message = "No hazards recorded for this zone."),
          rownames = FALSE, options = list(dom = "t")
        ))
      }

      display        <- h
      display$Score  <- display$Likelihood * display$Impact
      display        <- display[order(-display$Score), ]
      display        <- display[, c("Hazard", "Likelihood", "Impact", "Score",
                                    "Elimination", "Mitigation")]

      datatable(
        display,
        rownames  = FALSE,
        selection = "none",
        options   = list(
          dom         = "t",
          pageLength  = 20,
          columnDefs  = list(
            list(className = "dt-center", targets = c(1L, 2L, 3L)),
            list(width = "220px", targets = c(4L, 5L))
          )
        )
      ) |>
        formatStyle(
          "Score",
          backgroundColor = styleInterval(c(5, 11),
                                          c("#d1fae5", "#fef3c7", "#fee2e2")),
          fontWeight = "bold"
        )
    })

    # -----------------------------------------------------------------------
    # TAB 1 — TOOL CONTROLS
    # -----------------------------------------------------------------------

    output$tool_controls <- renderUI({
      td <- active_tools()

      if (nrow(td) == 0) {
        return(tags$p(
          "No tools selected. Use the checklist on the left.",
          class = "text-muted"
        ))
      }

      cards <- lapply(seq_len(nrow(td)), function(i) {
        tool        <- td[i, ]
        level       <- tool$BaseRisk
        badge_bg    <- if (level == 5) "#dc3545"
                       else if (level >= 3) "#fd7e14"
                       else "#28a745"

        div(
          class = "well",
          style = "padding: 10px 14px; margin-bottom: 8px;",
          fluidRow(
            column(8, tags$strong(tool$Tool)),
            column(4,
              tags$span(
                paste0("Class ", level),
                style = paste0(
                  "background-color:", badge_bg, "; color:white; padding:2px 8px;",
                  " border-radius:3px; float:right; font-size:11px; font-weight:bold;"
                )
              )
            )
          ),
          tags$p(
            tool$ToolControls,
            style = "font-size:12px; margin:6px 0 0 0; color:#495057;"
          )
        )
      })

      tagList(cards)
    })

    # -----------------------------------------------------------------------
    # TAB 2 HELPERS
    # -----------------------------------------------------------------------

    student_avg <- reactive({
      req(input$compare_tool)
      subs      <- submissions()
      tool_subs <- subs[subs$Tool == input$compare_tool, ]
      if (nrow(tool_subs) == 0) return(list(avg = 3.0, n = 0L))
      list(avg = round(mean(tool_subs$Vote, na.rm = TRUE), 1),
           n   = nrow(tool_subs))
    })

    # -----------------------------------------------------------------------
    # TAB 2 — COMPARISON CHART
    # -----------------------------------------------------------------------

    output$comparison_chart <- renderPlot({
      req(input$compare_tool)
      tools    <- tool_registry()
      tool_def <- tools[tools$Tool == input$compare_tool, ]
      if (nrow(tool_def) == 0) return(NULL)

      avg_info <- student_avg()

      chart_df <- data.frame(
        Profile = c(
          "Teacher\nBaseline",
          "AI\nEngine",
          "Last\nSemester",
          paste0("Current Class\n(N=", avg_info$n, ")")
        ),
        Rating = c(
          tool_def$Teacher_Risk,
          tool_def$AI_Risk,
          tool_def$Hist_Risk,
          avg_info$avg
        ),
        Color = c("#059669", "#2563eb", "#ca8a04", "#f59e0b"),
        stringsAsFactors = FALSE
      )
      chart_df$Profile <- factor(chart_df$Profile, levels = chart_df$Profile)

      ggplot(chart_df, aes(x = Profile, y = Rating, fill = Profile)) +
        geom_col(width = 0.55, show.legend = FALSE) +
        geom_text(
          aes(label = Rating),
          vjust = -0.4, fontface = "bold", size = 5
        ) +
        scale_fill_manual(
          values = setNames(chart_df$Color, as.character(chart_df$Profile))
        ) +
        scale_y_continuous(limits = c(0, 5.6), breaks = 0:5) +
        labs(
          title = paste("Risk Profile Comparison:", input$compare_tool),
          x     = NULL,
          y     = "Risk Rating (1 – 5)"
        ) +
        theme_minimal(base_size = 13) +
        theme(
          plot.title    = element_text(face = "bold", colour = "#1e293b", size = 14),
          axis.text.x   = element_text(face = "bold", colour = "#334155", size = 11),
          panel.grid.major.x = element_blank()
        )
    })

    # -----------------------------------------------------------------------
    # TAB 2 — VARIANCE TABLE
    # -----------------------------------------------------------------------

    output$variance_table <- renderDT({
      req(input$compare_tool)
      tools    <- tool_registry()
      tool_def <- tools[tools$Tool == input$compare_tool, ]
      if (nrow(tool_def) == 0) return(NULL)

      avg_info <- student_avg()

      variance_df <- data.frame(
        Profile = c(
          "Teacher Baseline",
          "AI Engine Prediction",
          "Last Semester's Students",
          "Live Class Average"
        ),
        `Calculated Rating` = c(
          tool_def$Teacher_Risk,
          tool_def$AI_Risk,
          tool_def$Hist_Risk,
          avg_info$avg
        ),
        `Evaluation Remarks` = c(
          "Official statutory hazard control benchmark (NZ H&S at Work Act 2015).",
          "Calculated from agricultural machinery industry models.",
          "Historical consensus across 42 class portfolios.",
          paste0("Dynamic score compiled from ", avg_info$n,
                 " live inputs in the current session.")
        ),
        check.names     = FALSE,
        stringsAsFactors = FALSE
      )

      datatable(
        variance_df,
        rownames  = FALSE,
        selection = "none",
        options   = list(dom = "t", pageLength = 4)
      )
    })

    # -----------------------------------------------------------------------
    # TAB 3 — SUBMIT ASSESSMENT
    # -----------------------------------------------------------------------

    observeEvent(input$submit_assessment, {
      coord   <- trimws(input$input_coord)
      comment <- trimws(input$input_comment)

      if (!nzchar(coord) || !nzchar(comment)) {
        showNotification(
          "Please fill in the Coordinate and Justification fields before submitting.",
          type = "error", duration = 5
        )
        return()
      }

      new_entry <- data.frame(
        Tool      = input$input_tool,
        Vote      = as.integer(input$input_risk),
        Coord     = coord,
        Comment   = comment,
        Timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        stringsAsFactors = FALSE
      )

      updated <- rbind(new_entry, submissions())
      save_risk_submissions(updated)
      submissions(updated)

      # Reset form
      updateTextInput(session,    "input_coord",   value = "")
      updateTextAreaInput(session,"input_comment",  value = "")
      updateSliderInput(session,  "input_risk",     value = 3L)

      showNotification(
        paste0("Assessment for '", input$input_tool, "' submitted and saved."),
        type = "message", duration = 4
      )
    })

    # -----------------------------------------------------------------------
    # TAB 3 — LIVE FEED
    # -----------------------------------------------------------------------

    output$vote_count <- renderText({
      paste(nrow(submissions()), "entries logged")
    })

    output$live_feed_table <- renderDT({
      subs <- submissions()

      if (nrow(subs) == 0) {
        return(datatable(
          data.frame(Message = "No assessments submitted yet."),
          rownames = FALSE, options = list(dom = "t")
        ))
      }

      display <- subs[, c("Tool", "Vote", "Coord", "Comment", "Timestamp"),
                      drop = FALSE]
      colnames(display) <- c("Tool", "Rating", "Location", "Justification", "Submitted")

      datatable(
        display,
        rownames  = FALSE,
        selection = "none",
        options   = list(
          pageLength = 8,
          order      = list(list(4L, "desc")),
          columnDefs = list(
            list(className = "dt-center", targets = 1L),
            list(width = "260px", targets = 3L)
          )
        )
      ) |>
        formatStyle(
          "Rating",
          backgroundColor = styleInterval(c(2, 3),
                                          c("#d1fae5", "#fef3c7", "#fee2e2")),
          fontWeight = "bold"
        )
    })
  })
}

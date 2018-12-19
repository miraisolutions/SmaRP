if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    titlePanel("withModalSpinner"),
    actionButton("trigger_runif", "Trigger...", icon("cog")),
    actionButton("trigger_expr", "Trigger...", icon("cog"))
  )

  slow_runif <- function(time) c(Sys.sleep(time), runif(1))
  server <- function(input, output) {
    observeEvent(input$trigger_runif, {
      withModalSpinner(
        message(slow_runif(2)),
        "Waiting for a slow runif...",
        size = "s"
      )
    })
    observeEvent(input$trigger_expr, {
      withModalSpinner(
        {
          Sys.sleep(1)
          for (i in 1:10) {
            message(i)
            Sys.sleep(0.1)
          }
        },
        "Waiting for a slow expression..."
      )

    })
  }
  # Run the application
  shiny::runApp(shiny::shinyApp(ui = ui, server = server), launch.browser = TRUE)
}

if (interactive()) {
  library(shiny)
  long_title <- "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt."
  ui <- fluidPage(
    tags$head(
      includeCSS(system.file("application/www/style.css", package = "SmaRP"))
    ),
    titlePanel("SmaRPanel"),
    icon("cog"),
    fluidRow(
      column(3L, SmaRPanel(
        id = "simple-panel", title = long_title,
        verticalLayout(textInput("a", "A"), textInput("b", "B"))
      )),
      column(3L, SmaRPanel(
        id = "collapsed-panel", title = long_title,
        verticalLayout(textInput("a", "A"), textInput("b", "B")),
        collapsed = TRUE
      )),
      column(3L, SmaRPanel(
        id = "expanded-panel", title = long_title,
        verticalLayout(textInput("a", "A"), textInput("b", "B")),
        collapsed = TRUE
      ))
    )
  )
  server <- function(input, output) {}
  runApp(shinyApp(ui = ui, server = server), launch.browser = TRUE)
}

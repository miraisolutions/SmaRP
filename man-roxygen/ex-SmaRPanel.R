if (interactive()) {
  library(shiny)
  long_title <- "Lorem ipsum dolor sit amet, consectetur adipisicing elit."
  ui <- fluidPage(
    tags$head(
      includeCSS(system.file("application/www/style.css", package = "SmaRP"))
    ),
    titlePanel("SmaRPanel"),
    icon("cog"),
    fluidRow(
      column(2L, SmaRPanel(
        id = "simple-panel", title = long_title,
        verticalLayout(textInput("a", "A"), textInput("b", "B"))
      )),
      column(2L, SmaRPanel(
        id = "collapsed-panel", title = long_title,
        verticalLayout(textInput("a", "A"), textInput("b", "B")),
        collapsed = FALSE
      )),
      column(2L, SmaRPanel(
        id = "expanded-panel", title = long_title,
        verticalLayout(textInput("a", "A"), textInput("b", "B")),
        collapsed = TRUE
      )),
      column(2L, SmaRPanel(
        id = "no-title-panel",
        verticalLayout(textInput("a", "A"), textInput("b", "B"))
      )),
      column(2L, SmaRPanel(
        id = "no-title-expanded-panel",
        verticalLayout(textInput("a", "A"), textInput("b", "B")),
        collapsed = FALSE
      ))
    )
  )
  server <- function(input, output) {}
  runApp(shinyApp(ui = ui, server = server), launch.browser = TRUE)
}

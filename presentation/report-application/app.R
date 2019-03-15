library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  #img(src = "./report.png", align = "center")
  tags$iframe(style = "height:600px; width:100%", src = "./SmaRPreport.20190315.pdf")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
}

# Run the application
shinyApp(ui = ui, server = server)


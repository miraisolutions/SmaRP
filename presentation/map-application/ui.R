library(shiny)
library(shinyBS)
#library(shinythemes)

source(system.file("application", "global.R", package = "SmaRP"))
#source(system.file("application", "helper_texts.R", package = "SmaRP"))

# #FF9966 Mirai Orange
# #008cc3 Mirai blue
# #189bce background header
# #ea8b5b title orange

# UI
shinyUI(
  fluidPage(
    theme = system.file("application", "style.css", package = "SmaRP"),
    titlePanel("Tax Amount distribution at municipality level"),
    hr(),
    sidebarPanel(
        numericInput("Salary", label = h5("Current Annual Salary"), value = 100000, step = 1000, min = 0),
        bsTooltip("Salary", IB$Salary, placement = "right", options = list(container = "body")),
        numericInput("Age", label = h5("Current Age"), value = 40, step = 1, min = 14),
        # selectInput("postalcode", label = h5("Postal Code"),
        #             choices = PLZ.list,
        #             selected = "8001"),
        numericInput("NKids", label = h5("Number of Children"), value = 2, min = 0, max = 9),
        bsTooltip("NKids", IB$NKids, placement = "right", options = list(container = "body")),
      checkboxInput("churchtax", "Church affiliation", TRUE),
        # radioButtons("genre", label = NULL, inline = TRUE,
        #              choices = list("Male" = "M", "Female" = "F"),
        #              selected = "M"),
        radioButtons("rate_group", label = NULL, inline = TRUE,
                     choices = Rate_group.list,
                     selected = "C"),
        bsTooltip("rate_group", IB$rate_group, placement = "right", options = list(container = "body")),
      # Button
      downloadButton("downloadData", "Download Data"),
      style = "margin-left: 2%;"
    ),
    mainPanel(
        plotOutput("plot1")
    )
  )
)

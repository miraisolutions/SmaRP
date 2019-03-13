library(SmaRP)
library(shiny)
library(dplyr)
library(ggplot2)
library(stats)
#library(leaflet)

source("/home/mirai/Desktop/Rprojects/SmaRP/presentation/map-application/core.R")
source("/home/mirai/Desktop/Rprojects/SmaRP/presentation/map-application/map-global.R")
source("/home/mirai/Desktop/Rprojects/SmaRP/inst/application/global.R")
#source(system.file("application", "helper_texts.R", package = "SmaRP"))
options(shiny.sanitize.errors = TRUE)


# Server ----------------------------------------------------------------
shinyServer(function(input, output, session) {

  # input parameters ----------

  # RetirementAge <- reactive({
  #   if (genre()=="M"){
  #     MRetirementAge
  #   } else {
  #     FRetirementAge
  #   }
  # })

  # TaxRelief <- reactive({
  #   if (input$rate_group == "C"){
  #     2* MaxContrTax
  #   }else{
  #     MaxContrTax
  #   }
  # })

  NKids <- reactive({isnotAvailableReturnZero(input$NKids)})

  rate_group <- reactive({
    need(input$rate_group, VM$rate_group)
    input$rate_group
  })

  churchtax <- reactive({
    if (input$churchtax == TRUE) {
      "Y"
    } else {
      "N"
    }
  })

  Salary <- reactive({
    validate(
      need(input$Salary, VM$Salary)
    )
    input$Salary
  })

  Age <- reactive({
    validate(
      need(input$Age, "Age is a mandatory input")
    )
    input$Age
  })

  # params ----
  #params list to be passed to the output
  params <- reactive(list(Salary = Salary(),
                          #postalcode = postalcode(),
                          #Kanton = returnPLZKanton(postalcode()),
                          NKids = NKids(), #ifelse((input$NKids) >5, 5, (input$NKids)),
                          churchtax = churchtax(),
                          rate_group = rate_group(),
                          Age = Age()
                          #PLZGemeinden = PLZGemeinden,
                          # AHL = AHL,
                          # ALV = ALV,
                          # VersicherungsL = VersicherungsL,
                          # VersicherungsV= VersicherungsV,
                          # VersicherungsK = VersicherungsK,
                          # DOV = DOV,
                          # Kinder = Kinder,
                          # Verheiratet = Verheiratet
  )
  )

  # plot -----

  map.gemeinde.df <- reactive({
    makeMap(map.gemeinde, Salary(), input$rate_group, Age(), NKids(), churchtax())
  })

  output$plot1 <- renderPlot({
    d <- map.gemeinde.df()
    p <- makePlot(d)
    expr = plot(p)
    # width = "400px"
    # height = "300px"
  })

  # renderLeaflet({
  #   leaflet(map.gemeinde) %>%
  #     addPolygons()
  # })

  # test output -----
  #output$table <- renderTable({map = map.gemeinde.df() })

  # output$downloadData <- downloadHandler(
  #   filename = function() {
  #     paste("map.gemeinde.df.rds", sep = "")
  #   },
  #   content = function(file) {
  #     saveRDS(map.gemeinde.df(), file)
  #   }
  # )

  output$downloadData <- downloadHandler(
    filename = function() {
      paste("params.rds", sep = "")
    },
    content = function(file) {
      saveRDS(params(), file)
    }
  )


})

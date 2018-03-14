library(shiny)
library(shinyBS)
#library(shinydashboard)
source("external_inputs.R")

# UI
shinyUI( 
  fluidPage(
    theme = "style.css",
    fluidRow(
      # tags$head(
      #   tags$style(HTML("hr {border-top: 1px solid #000000;}"))
      # ),
      titlePanel(
        fluidRow(
          column(7,
                 fluidRow(h2("SmaRP: Smart Retirement Planning")),
                 fluidRow(a(href="http://www.mirai-solutions.com", "mirai-solutions.com"))
          ), # end of first column
          column(4, 
                 img(src='mirai.pdf', align = "right", height = 100, width = 300)), # end of second column
          column(1) # empty column to have the logo no too much to the right
        ) #end of fluid row
      ), # end of title panel
      hr()
    ), #end of FluidRow
    fluidRow(
      column(4,
             tabsetPanel(
               id = "inputs",
               type = "tabs",
               tabPanel(
                 title = "Personal Input", 
                 value = "Personal",
                 br(),
                 fluidRow( dateInput("Birthdate", label = h5("Birthday"), value = "1980-12-31", format = "yyyy-mm-dd"),
                           style = "margin-left: 30px;"),
                 fluidRow(numericInput("RetirementAge", label = h5("Desired Retirement Age"), value = 65, step = 1, min = 55, max = 70),
                          style = "margin-left: 30px;"),
                 hr(),
                 fluidRow( tags$h4("Private Pension Fund"), style = "margin-left: 30px;"),
                 #infoBoxOutput("ibox",width = 0.5),
                 fluidRow(
                 numericInput("CurrentP3", label = h5("Current amount"), value = 50000, step = 1000, min = 0),
                 bsTooltip("CurrentP3", "This explaind CurrentP3", placement = "right", options = list(container = "body")),
                 style = "margin-left: 30px;"),
                 fluidRow(
                 column( 6, numericInput("P3purchase", label = h5("Annual contribution"), value = 0, step = 500, min = 0),
                 bsTooltip("P3purchase", "This explaind P3purchase", placement = "right", options = list(container = "body"))),
                 column( 6, numericInput("returnP3", label = h5("Expected Return"), value = BVGMindestzinssatz, step = 0.001, min = 0),
                 bsTooltip("returnP3", "This explaind returnP3", placement = "right", options = list(container = "body"))),
                 style = "margin-left: 20px;")
                ), #end of Personal Input tabPanel
               tabPanel(
                 title = "Residence Input", 
                 value = "Residence",
                 br(),
                 tabsetPanel(
                   id = "case",
                   type = "pills",
                   tabPanel(title = "General case", 
                            value = "General",
                            fluidRow( tags$h4("Tax Benefits"),style = "margin-left: 20px;"),
                            fluidRow( numericInput("TaxRelief", label = h5("Maximum Tax Relief"), value = 10000, step = 100, min = 0),
                            bsTooltip("TaxRelief", "This explaind TaxRelief", placement = "right", options = list(container = "body")),
                            style = "margin-left: 30px;"),
                            fluidRow( numericInput("TaxRate", label = h5("Marginal Tax Rate"), value = 0.1, step = 0.01, min = 0),
                            bsTooltip("TaxRate", "This explaind TaxRate", placement = "right", options = list(container = "body")),
                            style = "margin-left: 30px;"),
                            hr(),
                            wellPanel(
                              checkboxInput("provideTaxRateGen", "Direct Tax Rate (optional)", FALSE),
                              uiOutput("conditionalInputGen"), 
                              style = "margin-left: 20px;margin-right: 20px;"
                            )
                   ), # end General tabPanel
                   tabPanel(title = "Swiss case",
                            value = "Swiss",
                            fluidRow(tags$h4("Parameters for Tax Rate ecaluation"),style = "margin-left: 20px;"),
                            fluidRow(column( 6, selectInput("postalcode", label = h5("Postal Code"),
                                        choices = PLZ.list,
                                        selected = "8001")),
                                     column( 6, numericInput("NKids", label = h5("Number of Children"), value = 0, min = 0, max = 5),
                                             bsTooltip("NKids", "5 maximum number of children treated separatedly, for simplicity.", placement = "right", options = list(container = "body"))),
                                        style = "margin-left: 20px;"),
                            fluidRow(radioButtons("genre", label = NULL, inline = TRUE,
                                         choices = list("Male" = "M", "Female" = "F"), 
                                         selected = "M"), style = "margin-left: 30px;"),
                            fluidRow(radioButtons("rate_group", label = NULL, inline = TRUE, 
                                         choices = Rate_group.list, 
                                         selected = "A"),style = "margin-left: 30px;"),
                            #tags$small("* If more then 5 Kids, treated as if 5"),
                            #br(),
                            fluidRow(radioButtons("churchtax", label = h5("Church affiliation"), inline = TRUE,
                                         choices = list("Y" = "Y", "N" = "N"), 
                                         selected = "N"),style = "margin-left: 30px;"),
                            hr(),
                              wellPanel(
                              checkboxInput("provideTaxRateSwiss", "Direct Tax Rate (optional)", FALSE),
                              uiOutput("conditionalInputSwiss"),
                              style = "margin-left: 20px;margin-right: 20px;"
                            ),
                            hr(),
                            fluidRow(tags$h4("Occupational Pension Fund (BVG)"),style = "margin-left: 20px;"),
                            fluidRow(
                              column( 6,numericInput("Salary", label = h5("Current Annual Salary"), value = 100000, step = 1000, min = 0)),
                              column( 6,numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.02, step = 0.001, min = 0),
                                      bsTooltip("SalaryGrowthRate", "This explaind SalaryGrowthRate", placement = "right", options = list(container = "body"))),
                            style = "margin-left: 20px;"),
                            fluidRow(
                              column( 6, numericInput("CurrentP2", label = h5("Current BVG amount"), value = 100000, step = 1000, min = 0),
                                    bsTooltip("CurrentP2", "This explaind CurrentP2", placement = "right", options = list(container = "body"))),
                              column( 6, numericInput("P2purchase", label = h5("Voluntary purchases"), value = 0, step = 500, min = 0),
                                    bsTooltip("P2purchase", "This explaind P2purchase", placement = "right", options = list(container = "body"))),
                              style = "margin-left: 20px;"),
                            br(),
                            fluidRow(
                            radioButtons("TypePurchase", label = NULL, inline = TRUE,  choices = Purchase.list),
                            bsTooltip("TypePurchase", "This explaind TypePurchase", placement = "right", options = list(container = "body")),
                            style = "margin-left: 35px;"),
                            hr(),
                            fluidRow( actionButton("refreshButton", "refresh calculation parameters"),
                            #p("Refresh tax rate information"),
                            verbatimTextOutput("refreshText"),
                            style = "margin-left: 30px;")
                   ) #  end Swiss tabPanel
                 ) # end of tabsetPanel
               ) # end of tab panel
             ) # end of tabsetPanel
      ), #end first column
      column(8, 
             tabsetPanel(
               type = "pills",
               tabPanel("Plot", 
                        #                   hr(),
                        fluidRow(align="center",  verbatimTextOutput("Totals")),
                        fluidRow(align="center",  htmlOutput("plot1")),
                        fluidRow(align="center", htmlOutput("plot2"))
               ), # end tab Plot
               
               tabPanel("Table", 
                        htmlOutput("table")
               ) # end tab Table
               
             ), # end tabsetPanel
             
             fluidRow(align="left", 
             #Disclaimer
             verbatimTextOutput("disclaimer")),
             # tags$head(tags$style("#Totals{
             #                      font-family:Helvetica;
             #                      color: blue;
             #                      font-size: 20px;
             #                      font-style: bold;
             #                      text-align: center;
             #                      }"),
             #           tags$style("#disclaimer{
             #                      font-family:Helvetica;
             #                      color: grey;
             #                      font-size: 12px;
             #                      text-align: left;
             #                      }")),
             fluidRow(align="left", 
             #Add button to download report
             downloadButton("report", "Generate report"))
      ) #end second column/main panel
    ) #end of FluidRow
  ) # end of fluidPage
) #end of shinyUI
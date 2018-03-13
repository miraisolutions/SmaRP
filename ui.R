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
      img(src='mirai.pdf', align = "right", height = 100, width = 250),
      titlePanel("SmaRP: Smart Retirement Planning"),
      a(href="http://www.mirai-solutions.com", "mirai-solutions.com"),
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
                 dateInput("Birthdate", label = h5("Birthday"), value = "1980-12-31", format = "yyyy-mm-dd"),
                 numericInput("RetirementAge", label = h5("Desired Retirement Age"), value = 65, step = 1, min = 55, max = 70),
                 hr(),
                 tags$h4("Private Pension Fund"),
                 #infoBoxOutput("ibox",width = 0.5),
                 numericInput("CurrentP3", label = h5("Current amount"), value = 50000, step = 1000, min = 0),
                 bsTooltip("CurrentP3", "This explaind CurrentP3", placement = "right", options = list(container = "body")),
                 numericInput("P3purchase", label = h5("Annual contribution"), value = 0, step = 500, min = 0),
                 numericInput("returnP3", label = h5("Expected Return"), value = BVGMindestzinssatz, step = 0.001, min = 0)    
               ), #end of Personal Input tabPanel
               tabPanel(
                 title = "Residence Input", 
                 value = "Residence",
                 
                 tabsetPanel(
                   id = "case",
                   type = "pills",
                   tabPanel(title = "General case", 
                            value = "General",
                            tags$h4("Tax Benefits"),
                            numericInput("TaxRelief", label = h5("Maximum Tax Relief"), value = 10000, step = 100, min = 0),
                            numericInput("TaxRate", label = h5("Marginal Tax Rate"), value = 0.1, step = 0.01, min = 0)
                   ), # end General tabPanel
                   tabPanel(title = "Swiss case",
                            value = "Swiss",
                            selectInput("postalcode", label = h5("Postal Code"),
                                        choices = PLZ.list,
                                        selected = "8001"),
                            radioButtons("genre", label = NULL, inline = TRUE,
                                         choices = list("Male" = "M", "Female" = "F"), 
                                         selected = "M"),
                            radioButtons("rate_group", label = NULL, inline = TRUE, 
                                         choices = Rate_group.list, 
                                         selected = "A"),
                            numericInput("NKids", label = h5("Number of Kids"), value = 0, min = 0, max = 5),
                            tags$p("* If more then 5 Kids, treated as if 5"),
                            radioButtons("churchtax", label = h5("Church affiliation"), inline = TRUE,
                                         choices = list("Y" = "Y", "N" = "N"), 
                                         selected = "N"),
                            hr(),
                            wellPanel(
                              checkboxInput("provideTaxRate", "Direct Tax Rate (optional)", FALSE),
                              uiOutput("conditionalInput")
                            ),
                            hr(),
                            tags$h4("Occupational Pension Fund (BVG)"),
                            numericInput("Salary", label = h5("Current Annual Salary"), value = 100000, step = 1000, min = 0),
                            numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.02, step = 0.001, min = 0),
                            numericInput("CurrentP2", label = h5("Current BVG amount"), value = 100000, step = 1000, min = 0),
                            numericInput("P2purchase", label = h5("Voluntary purchases"), value = 0, step = 500, min = 0),
                            radioButtons("TypePurchase", label = NULL, inline = TRUE,
                                         choices = Purchase.list),
                            hr(),
                            actionButton("refreshButton", "refresh calculation parameters"),
                            #p("Refresh tax rate information"),
                            verbatimTextOutput("refreshText")
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
                        verbatimTextOutput("Totals"),
                        htmlOutput("plot1"),
                        htmlOutput("plot2")
               ), # end tab Plot
               
               tabPanel("Table", 
                        htmlOutput("table")
               ) # end tab Table
               
             ), # end tabsetPanel
             
             #Disclaimer
             verbatimTextOutput("disclaimer"),
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
             
             #Add button to download report
             downloadButton("report", "Generate report")
      ) #end second column/main panel
    ) #end of FluidRow
  ) # end of fluidPage
) #end of shinyUI
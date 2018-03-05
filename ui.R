#
# SmarP UI
# runApp()
#


library(shiny)
source("external_inputs.R")

# UI
shinyUI( 
  fluidPage(
    tags$head(
      tags$style(HTML("hr {border-top: 1px solid #000000;}"))
    ),
    
    titlePanel("Swiss Retirement Calculator"),
    a(href="http://www.mirai-solutions.com", "mirai-solutions.com"),
    hr(),
    sidebarLayout(
      sidebarPanel(
        width = 3,
        dateInput("Birthdate", label = h5("Birthday"), value = "1980-12-31", format = "yyyy-mm-dd"),
        numericInput("RetirementAge", label = h5("Desired Retirement Age"), value = 65, step = 1, min = 55, max = 70),
        hr(),
        tags$h4("Private Pension Fund"),
        numericInput("CurrentP3", label = h5("Current amount"), value = 50000, step = 1000, min = 0),
        numericInput("P3purchase", label = h5("Annual contribution"), value = 0, step = 500, min = 0),
        numericInput("returnP3", label = h5("Expected Return"), value = BVGMindestzinssatz, step = 0.001, min = 0),
        hr(),
        
        tabsetPanel(
          id = "case",
          type = "tabs",
          tabPanel(title = "General case", 
                   value = "General",
                   tags$h4("Tax Benefits"),
                   numericInput("TaxRelief", label = h5("Maximum Tax Relief"), value = 10000, step = 100, min = 0),
                   numericInput("TaxRate", label = h5("Marginal Tax Rate"), value = 0.1, step = 0.01, min = 0)
                   
          ), # end General tabPanel
          
          tabPanel(title = "Swiss case",
                   value = "Swiss",
                   selectInput("kanton", "Basic Info",
                               choices = Kanton.list ,
                               selected = "ZH"),
                   actionButton("refreshButton", "refresh tax rate"),
                   #p("Refresh tax rate information"),
                   verbatimTextOutput("refreshText"),
                   radioButtons("genre", label = NULL, inline = TRUE,
                                choices = list("Male" = "M", "Female" = "F"), 
                                selected = "M"),
                   selectInput("tariff", label = NULL, 
                               choices = tariffs.list, 
                               selected = "TA"),
                   radioButtons("NKids", label = NULL, inline = TRUE,
                                choices = Kids.list,
                                selected = "0kid"),
                   
                   hr(),
                   tags$h4("Occupational Pension Fund (BVG)"),
                   numericInput("Salary", label = h5("Current Annual Salary"), value = 100000, step = 1000, min = 0),
                   numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.02, step = 0.001, min = 0),
                   numericInput("CurrentP2", label = h5("Current BVG amount"), value = 100000, step = 1000, min = 0),
                   numericInput("P2purchase", label = h5("Voluntary purchases"), value = 0, step = 500, min = 0),
                   radioButtons("TypePurchase", label = NULL, inline = TRUE,
                                choices = Purchase.list)
                   
          ) #  end Swiss tabPanel
          
        ) # end tabsetPanel
        
      ), # end sidebarPanel
      
      # Show results
      mainPanel(
        tabsetPanel(
          type = "pills",
          tabPanel("Plot", 
                   #                   hr(),
                   verbatimTextOutput("Totals"),
                   htmlOutput("plot1"),
                   htmlOutput("plot2"),
                   verbatimTextOutput("disclaimer"),
                   tags$head(tags$style("#Totals{
                                        font-family:Helvetica;
                                        color: blue;
                                        font-size: 20px;
                                        font-style: bold;
                                        text-align: center;
                                        }"),
                             tags$style("#disclaimer{
                                        font-family:Helvetica;
                                        color: grey;
                                        font-size: 12px;
                                        text-align: left;
                                        }"))
          ), # end tab Plot
          
          tabPanel("Table", 
                   htmlOutput("table")
          ) # end tab Table
          
                   ), # end tabsetPanel
        
        #Add button to download report
        downloadButton("report", "Generate report")
        
                   ) # end mainPanel
      
        ) # end sidebarLayout
    
      ) # end fluidPage
  
    ) # end UI
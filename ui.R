library(shiny)
library(shinyBS)
library(shinythemes)
#library(shinydashboard)
source("external_inputs.R")
source("helper_texts.R")


# #FF9966 Mirai Orange
# #008cc3 Mirai blue
# #189bce background header
# #ea8b5b title orange

# UI
shinyUI( 
  fluidPage(
    # add "title" tag within the head of the html page
    titlePanel(title = NULL, windowTitle = "SmaRP: Smart Retirement Planning"),
    #themeSelector(),
    theme = "style.css",
    fluidRow(
      # tags$head(
      #   tags$style(HTML("hr {border-top: 1px solid #000000;}"))
      # ),
      fluidRow(img(src='mirai.png', align = "right",  height = "10%", width = "10%"), style = "margin-top: 10px;margin-right: 30px;margin-bottom: 10px;"),
      #titlePanel(
        fluidRow(
          id="head1",
          column(7,
                 fluidRow(h2("SmaRP:")),
                 fluidRow(h3("Smart Retirement Planning"))
          ), # end of first column
          # column(4, 
          #        fluidRow(img(src='mirai.png', align = "right",  height = "70%", width = "70%"), style = "margin-top: 20px;")#, height = 100, width = 300
          #        #fluidRow(a(href="http://www.mirai-solutions.com", "mirai-solutions.com"),align="right",style = "margin-right: 10px;" )
          #        ), # end of second column
          # column(1) # empty column to have the logo no too much to the right
          style = "margin: 10px;" 
        ) #end of fluid row
      #)#, # end of title panel
      #hr()
    ), #end of FluidRow
    fluidRow(
      column(4,
             tabsetPanel(
               id = "inputs",
               type = "tabs",
               tabPanel(
                 title = "Generic Inputs", 
                 value = "Personal",
                 br(),
                 fluidRow( dateInput("Birthdate", label = h5("Birthdate"), value = "1980-12-31", format = "yyyy-mm-dd"),
                           style = "margin-left: 30px;"),
                 wellPanel(
                   checkboxInput("provideRetirementAge", "Desired Retirement Age (optional)", FALSE),
                   uiOutput("conditionalRetirementAge"),
                   style = "margin-left: 20px;margin-right: 20px;"
                 ),
                 hr(),
                 fluidRow( tags$h4("Private Pension Fund"), style = "margin-left: 30px;"),
                 #infoBoxOutput("ibox",width = 0.5),
                 fluidRow(
                   numericInput("CurrentP3", label = h5("Current assets"), value = 50000, step = 1000, min = 0),
                   bsTooltip("CurrentP3", IB$CurrentP3, placement = "right", options = list(container = "body")),
                   style = "margin-left: 30px;"),
                 fluidRow(
                   column( 6, numericInput("P3purchase", label = h5("Annual contribution"), value = 0, step = 500, min = 0),
                           bsTooltip("P3purchase", IB$P3purchase, placement = "right", options = list(container = "body"))),
                   column( 6, numericInput("returnP3", label = h5("Expected Return"), value = BVGMindestzinssatz, step = 0.001, min = 0, max = 0.25),
                           bsTooltip("returnP3", IB$returnP3, placement = "right", options = list(container = "body"))),
                   style = "margin-left: 20px;")
               ), #end of Personal Input tabPanel
               tabPanel(
                 title = "Particular cases", 
                 value = "Residence",
                 br(),
                 tabsetPanel(
                   id = "case",
                   type = "pills",
                   tabPanel(title = "General case", 
                            value = "General",
                            fluidRow( tags$h4("Tax Benefits"),style = "margin-left: 20px;"),
                            fluidRow( numericInput("TaxRelief", label = h5("Maximum Tax Relief"), value = 10000, step = 100, min = 0),
                                      bsTooltip("TaxRelief", IB$TaxRelief, placement = "right", options = list(container = "body")),
                                      style = "margin-left: 30px;"),
                            fluidRow( numericInput("TaxRate", label = h5("Marginal Tax Rate"), value = 0.1, step = 0.01, min = 0, max = 0.9),
                                      bsTooltip("TaxRate", IB$TaxRate, placement = "right", options = list(container = "body")),
                                      style = "margin-left: 30px;")
                            #,fluidRow( selectInput("currency", label = h5("Currency"), selected = "CHF", choices = currencies.list)
                            #          , style = "margin-left: 30px;")
                   ), # end General tabPanel
                   tabPanel(title = "Swiss case",
                            value = "Swiss",
                            conditionalPanel(condition= 'input.provideTaxRateSwiss==""',
                                             #                    fluidRow(tags$h4("Parameters for Tax Rate ecaluation"),style = "margin-left: 20px;"),
                                             fluidRow(column( 6, selectInput("postalcode", label = h5("Postal Code"),
                                                                             choices = PLZ.list,
                                                                             selected = "8001")),
                                                      column( 6, numericInput("NKids", label = h5("Number of Children"), value = 0, min = 0, max = 9),
                                                              bsTooltip("NKids", IB$NKids, placement = "right", options = list(container = "body"))),
                                                      style = "margin-left: 20px;"),
                                             conditionalPanel(condition= 'input.provideRetirementAge==""',
                                                              fluidRow(radioButtons("genre", label = NULL, inline = TRUE,
                                                                                    choices = list("Male" = "M", "Female" = "F"), 
                                                                                    selected = "M"),
                                                                       style = "margin-left: 30px;")
                                                              ), # end conditional panel
                                             fluidRow(radioButtons("rate_group", label = NULL, inline = TRUE, 
                                                                   choices = Rate_group.list, 
                                                                   selected = "A"),
                                                      bsTooltip("rate_group", IB$rate_group, placement = "right", options = list(container = "body")),
                                                      style = "margin-left: 30px;"), 
                                             #br(),
                                             fluidRow(radioButtons("churchtax", label = h5("Church affiliation"), inline = TRUE,
                                                                   choices = list("Y" = "Y", "N" = "N"), 
                                                                   selected = "N"),
                                                      style = "margin-left: 30px;")
                            ), # end conditional panel
                            hr(),
                            wellPanel(
                              checkboxInput("provideTaxRateSwiss", "Direct Tax Rate (optional)", FALSE),
                              uiOutput("conditionalInputSwiss"),
                              style = "margin-left: 20px;margin-right: 20px;"
                            ),
                            hr(),
                            fluidRow(tags$h4("Occupational Pension Fund (BVG)"),style = "margin-left: 20px;"),
                            fluidRow(
                              column( 6,numericInput("Salary", label = h5("Current Annual Salary"), value = 100000, step = 1000, min = 0),
                                      bsTooltip("Salary", IB$Salary, placement = "right", options = list(container = "body"))),
                              column( 6,numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.02, step = 0.001, min = 0, max = 0.1),
                                      bsTooltip("SalaryGrowthRate", IB$SalaryGrowthRate, placement = "right", options = list(container = "body"))),
                              style = "margin-left: 20px;"),
                            fluidRow(
                              column( 6, numericInput("CurrentP2", label = h5("Current BVG assets"), value = 100000, step = 1000, min = 0),
                                      bsTooltip("CurrentP2", IB$CurrentP2, placement = "right", options = list(container = "body"))),
                              column( 6, numericInput("P2interestRate", label = h5("Interest Rate (optional)"), value = BVGparams$BVGMindestzinssatz, step = 0.01, min = BVGparams$BVGMindestzinssatz),
                                      bsTooltip("P2interestRate", IB$P2interestRate, placement = "right", options = list(container = "body"))),
                              style = "margin-left: 20px;"),
                            #br(),
                            fluidRow(
                              column( 6, numericInput("P2purchase", label = h5("Voluntary purchases"), value = 0, step = 500, min = 0),
                                      bsTooltip("P2purchase", IB$P2purchase, placement = "right", options = list(container = "body"))),
                              column( 6, radioButtons("TypePurchase", label = NULL, inline = FALSE,  choices = Purchase.list),
                                      bsTooltip("TypePurchase", IB$TypePurchase, placement = "right", options = list(container = "body")), style = "margin-top: 20px;"),
                              style = "margin-left: 20px;"),
                            hr(),
                            fluidRow( 
                              wellPanel(
                                checkboxInput("login", "login as an admin", FALSE),
                                uiOutput("conditionalrefreshButton"),
                                uiOutput("conditionalrefreshText"),
                                style = "margin-left: 20px;margin-right: 20px;"
                              )
                              #,style = "margin-left: 30px;"
                              ),
                            br()
                   ) #  end Swiss tabPanel
                 ) # end of tabsetPanel
               ) # end of tab panel
             ) # end of tabsetPanel
      ), #end first column
      column(8, 
             tabsetPanel(
               type = "pills",
               tabPanel(title = "Plot", 
                        value = "Plot", 
                        #                   hr(),
                        fluidRow(align="center", verbatimTextOutput("Totals")),
                        fluidRow(htmlOutput("plot1")),
                        fluidRow(htmlOutput("plot2"), style = "margin-left: 60px;")#,
                        #fluidRow(align="center", textOutput('safeError'))
               ), # end tab Plot
               
               tabPanel(title = "Table", 
                        value = "Table", 
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
    ), #end of FluidRow
    hr(),
    fluidRow(
      column(9, a(href="https://github.com/miraisolutions/swissretire.git",icon("github-square", "fa-2x"))),
      column(3, a(href="http://www.mirai-solutions.com", img(src='mirai.png', align = "right",  height = "20%", width = "40%")), align="right" )
      ,style = " margin-bottom: 10px;" 
      )
  ) # end of fluidPage
) #end of shinyUI
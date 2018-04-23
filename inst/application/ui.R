library(shiny)
library(shinyBS)
library(shinythemes)
#library(shinydashboard)
source("global.R")
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
        fluidRow(
          id="head1",
          column(1, 
                 fluidRow(a(href="https://github.com/miraisolutions/SmaRP.git", img(src='SmaRPStiker.png',  height = "90%", width = "90%")), style="margin-left: 10%;margin-top: 10%;margin-bottom: 10%;")
                 ),
          column(6,
                 fluidRow(h2("SmaRP:")),
                 fluidRow(h3("Smart Retirement Planning"))
          ), # end of first column
          # column(4, 
          style = "margin-left: 0.1%;" 
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
                 fluidRow( dateInput("Birthdate", label = h5("Birthdate"), value = "1980-12-31", format = "yyyy-mm-dd", width = '94%'),
                           style = "margin-left: 1%;"),
                 fluidRow(wellPanel(
                   checkboxInput("provideRetirementAge", "Desired Retirement Age (optional)", FALSE),
                   uiOutput("conditionalRetirementAge")
                 )
                 ,style = "margin-left:1%;margin-right: 2%;"
                 ),
                 hr(),
                 fluidRow( tags$h4("Private Pension Fund"), style = "margin-left: 1%;"),
                 #infoBoxOutput("ibox",width = 0.5),
                 fluidRow(
                   numericInput("CurrentP3", label = h5("Current assets"), value = 50000, step = 1000, min = 0, width = '94%'),
                   bsTooltip("CurrentP3", IB$CurrentP3, placement = "right", options = list(container = "body")),
                   style = "margin-left: 1%;"),
                 fluidRow(
                   column( 5, numericInput("P3purchase", label = h5("Annual contribution"), value = 0, step = 500, min = 0),
                           bsTooltip("P3purchase", IB$P3purchase, placement = "right", options = list(container = "body")), style = "margin-left: 0.5%;margin-right: 5%;"),
                   column( 5, numericInput("returnP3", label = h5("Expected Return"), value = BVGMindestzinssatz, step = 0.001, min = 0, max = 0.25),
                           bsTooltip("returnP3", IB$returnP3, placement = "right", options = list(container = "body")), style="margin-left:9%")
                   )
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
                            fluidRow( tags$h4("Tax Benefits"),style = "margin-left: 1%;"),
                            fluidRow( numericInput("TaxRelief", label = h5("Maximum Tax Relief"), value = 10000, step = 100, min = 0, width = '94%'),
                                      bsTooltip("TaxRelief", IB$TaxRelief, placement = "right", options = list(container = "body")),
                                      style = "margin-left: 1%;"),
                            fluidRow( numericInput("TaxRate", label = h5("Marginal Tax Rate"), value = 0.1, step = 0.01, min = 0, max = 0.9, width = '94%'),
                                      bsTooltip("TaxRate", IB$TaxRate, placement = "right", options = list(container = "body")),
                                      style = "margin-left: 1%;")
                            #,fluidRow( selectInput("currency", label = h5("Currency"), selected = "CHF", choices = currencies.list)
                            #          , style = "margin-left: 1%;")
                   ), # end General tabPanel
                   tabPanel(title = "Swiss case",
                            value = "Swiss",
                            conditionalPanel(condition= 'input.provideTaxRateSwiss==""',
                                             #                    fluidRow(tags$h4("Parameters for Tax Rate ecaluation"),style = "margin-left: 20px;"),
                                             fluidRow(column( 5, selectInput("postalcode", label = h5("Postal Code"),
                                                                             choices = PLZ.list,
                                                                             selected = "8001"), 
                                                              style = "margin-left: 0.5%;"),
                                                      column( 5, numericInput("NKids", label = h5("Number of Children"), value = 0, min = 0, max = 9),
                                                              bsTooltip("NKids", IB$NKids, placement = "right", options = list(container = "body")),
                                                              style =  "margin-left:3%;")
                                                      ),
                                             fluidRow(column( 6,
                                                   checkboxInput("churchtax", "Church affiliation", FALSE)),
                                             column(6, 
                                                    conditionalPanel(condition= 'input.provideRetirementAge==""',
                                                                     fluidRow(radioButtons("genre", label = NULL, inline = TRUE,
                                                                                           choices = list("Male" = "M", "Female" = "F"), 
                                                                                           selected = "M")
                                                                             ,style = "margin-top:7%;")
                                                    ) # end conditional panel
                                             )
                                             ),
                                             fluidRow( radioButtons("rate_group", label = NULL, inline = TRUE, 
                                                                   choices = Rate_group.list, 
                                                                   selected = "A"),
                                                      bsTooltip("rate_group", IB$rate_group, placement = "right", options = list(container = "body")),
                                                      style = "margin-left: 1%;")
                            ), # end conditional panel
                            hr(),
                            fluidRow(wellPanel(
                              checkboxInput("provideTaxRateSwiss", "Direct Tax Rate (optional)", FALSE),
                              uiOutput("conditionalInputSwiss"))
                              ,style = "margin-left:1%;margin-right: 2%;"
                            ),
                            hr(),
                            fluidRow(tags$h4("Occupational Pension Fund (BVG)"),style = "margin-left: 1%;"),
                            fluidRow(
                              column( 6,numericInput("Salary", label = h5("Current Annual Salary"), value = 100000, step = 1000, min = 0),
                                      bsTooltip("Salary", IB$Salary, placement = "right", options = list(container = "body"))),
                              column( 6,numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.005, step = 0.001, min = 0, max = 0.1),
                                      bsTooltip("SalaryGrowthRate", IB$SalaryGrowthRate, placement = "right", options = list(container = "body")))
                              ),
                            fluidRow(
                              column( 6, numericInput("CurrentP2", label = h5("Current BVG assets"), value = 100000, step = 1000, min = 0),
                                      bsTooltip("CurrentP2", IB$CurrentP2, placement = "right", options = list(container = "body"))),
                              column( 6, numericInput("P2interestRate", label = h5("Interest Rate % (optional)"), value = 100*BVGparams$BVGMindestzinssatz, step = 1, min = 100*BVGparams$BVGMindestzinssatz, max = 100),
                                      bsTooltip("P2interestRate", IB$P2interestRate, placement = "right", options = list(container = "body")))
                              ),
                            #br(),
                            fluidRow(
                              column( 6, numericInput("P2purchase", label = h5("Voluntary purchases"), value = 0, step = 500, min = 0),
                                      bsTooltip("P2purchase", IB$P2purchase, placement = "right", options = list(container = "body"))),
                              column( 6, radioButtons("TypePurchase", label = NULL, inline = FALSE,  choices = Purchase.list),
                                      bsTooltip("TypePurchase", IB$TypePurchase, placement = "right", options = list(container = "body")), style = "margin-top: 20px;")
                             )#,
                            # hr(),
                            # fluidRow( 
                            #   wellPanel(
                            #     checkboxInput("login", "login as an admin", FALSE),
                            #     uiOutput("conditionalrefreshButton"),
                            #     uiOutput("conditionalrefreshText")
                            #   )
                            #   #,style = "margin-left: 30px;"
                            #   ),
                            # br()
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
                        fluidRow(htmlOutput("plot2"), style = "margin-left: 7%;")#,
                        #fluidRow(align="center", textOutput('safeError'))
               ), # end tab Plot
               
               tabPanel(title = "Table", 
                        value = "Table", 
                        div(style='width:800px; overflow-x: scroll',
                            htmlOutput("table")
                        )
               ) # end tab Table
               
             ), # end tabsetPanel
             
             fluidRow(align="left", 
                      #Disclaimer
                      verbatimTextOutput("disclaimer")),
             fluidRow(align="left", 
                      #Add button to download report
                      downloadButton("report", "Generate report"),
                      style = "margin-left: 8.5%")
      ) #end second column/main panel
    ), #end of FluidRow
    hr(),
    fluidRow(
      column(9, id="git", a(href="https://github.com/miraisolutions/SmaRP.git", icon("github-square", "fa-2x")) # , title=IB$git),
             #bsTooltip("git", IB$git, placement = "right", options = list(container = "body"))
             ),
      column(3, a(href="http://www.mirai-solutions.com", img(src='mirai.png', align = "right",width = "40%")), align="right" ,style = "margin-bottom: 1%;")
      , style = "margin-right:0.1%"
      )
  ) # end of fluidPage
) #end of shinyUI
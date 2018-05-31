library(shiny)
library(shinyBS)
library(shinythemes)
source("global.R")
source("helper_texts.R")


# #FF9966 Mirai Orange
# #008cc3 Mirai blue
# #189bce background header
# #ea8b5b title orange

# UI ----------------------------------------------------------------------

shinyUI( 
  
  # Page ------------------------------------------------------------------
  
  fluidPage(
    
    # Style  --------------------------------------------------------------
    
    theme = "style.css",
    
    # Header  -------------------------------------------------------------
    
    fluidRow(
      id = "head1",
      column(1, 
             fluidRow(a(href = "https://github.com/miraisolutions/SmaRP.git", 
                        img(src    = 'SmaRPStiker.png',  
                            height = "90%", 
                            width  = "90%")), 
                      style = "margin-left: 10%;margin-top: 10%;margin-bottom: 10%;")),
      column(6,
             fluidRow(h2("SmaRP:")),
             fluidRow(h3("Smart Retirement Planning"))),
      style = "margin-left: 0.1%;"), # end of FluidRow / Header
    
    # Main  -------------------------------------------------------------
    
    fluidRow(
      
      # Sidebar  --------------------------------------------------------
      column(4,
             # Personal Info  -------------------------------------------
             fluidRow(
               tags$h4("Personal Info"), 
               style = "margin-left: 1%;"),
             
             # Birthdate
             fluidRow(
               dateInput("Birthdate", 
                         label  = h5("Birthdate"),  
                         value  = "1980-12-31", 
                         format = "yyyy-mm-dd", 
                         width  = '94%'),
               style = "margin-left: 1%;"),
             
             # Desired retirement age conditional panel
             fluidRow(
               wellPanel(
                 checkboxInput("provideRetirementAge", 
                               "Desired Retirement Age (optional)", 
                               FALSE),
                 bsTooltip("provideRetirementAge", 
                           IB$RetirementAgeOptional, 
                           placement = "right", 
                           options   = list(container = "body")),
                 uiOutput("conditionalRetirementAge"),
                 bsTooltip("conditionalRetirementAge", 
                           IB$RetirementAge, 
                           placement = "right", 
                           options   = list(container = "body"))
               ),style = "margin-left:1%;margin-right: 2%;"),
             
             # PLZ and Kids
             fluidRow(
               column(6, 
                      selectInput("postalcode", 
                                  label    = h5("Postal Code"),
                                  choices  = PLZ.list,
                                  selected = "8001")),
               column(6, 
                      numericInput("NKids", 
                                   label = h5("Number of Children"), 
                                   value = 0, 
                                   min   = 0, 
                                   max   = 9),
                      bsTooltip("NKids", 
                                IB$NKids, 
                                placement = "right", 
                                options = list(container = "body")))),
             
             # Church tax and gender
             fluidRow(
               column(6, 
                      checkboxInput("churchtax", 
                                    "Church affiliation", 
                                    FALSE)),
               column(6, 
                      conditionalPanel(condition = 'input.provideRetirementAge==""',
                                       fluidRow(
                                         radioButtons("genre", 
                                                      label    = NULL, 
                                                      inline   = TRUE,
                                                      choices  = list("Male" = "M", "Female" = "F"), 
                                                      selected = "M"),
                                         style = "margin-top:6%;margin-left:3%;")))),
             
             # Rate Group
             fluidRow(
               radioButtons("rate_group", 
                            label    = NULL, 
                            inline   = TRUE, 
                            choices  = Rate_group.list, 
                            selected = "A"),
               bsTooltip("rate_group",
                         IB$rate_group,
                         placement = "right", 
                         options = list(container = "body")),
               style = "margin-left: 1%;"),
             
             hr(),
             
             # Pillar II  -------------------------------------------------------------
             fluidRow(
               tags$h4("Occupational Pension Fund - Pillar II"),
               style = "margin-left: 1%;"),
             
             fluidRow(
               column(6,
                      numericInput("Salary", 
                                   label = h5("Current Annual Salary"), 
                                   value = 100000, 
                                   step  = 1000,
                                   min   = 0),
                      bsTooltip("Salary", 
                                IB$Salary, 
                                placement = "right", 
                                options   = list(container = "body"))),
               column(6,
                      numericInput("SalaryGrowthRate", 
                                   label = h5("Expected Salary Growth Rate %"), 
                                   value = 0.5, 
                                   step  = 0.1,
                                   min   = 0, 
                                   max   = 100),
                      bsTooltip("SalaryGrowthRate", 
                                IB$SalaryGrowthRate, 
                                placement = "right", 
                                options   = list(container = "body")))),
             
             fluidRow(
               column(6, 
                      numericInput("CurrentP2", 
                                   label = h5("Current BVG assets"), 
                                   value = 100000, 
                                   step  = 1000, 
                                   min   = 0),
                      bsTooltip("CurrentP2", 
                                IB$CurrentP2, 
                                placement = "right", 
                                options   = list(container = "body"))),
               column(6, 
                      numericInput("P2interestRate", 
                                   label = h5("Interest Rate % (optional)"), 
                                   value = 100*BVGMindestzinssatz, 
                                   step  = 1, 
                                   min   = 100*BVGMindestzinssatz, 
                                   max   = 100),
                      bsTooltip("P2interestRate", 
                                IB$P2interestRate, 
                                placement = "right", 
                                options   = list(container = "body")))),
             
             fluidRow(
               column(6, 
                      numericInput("P2purchase", 
                                   label = h5("Voluntary purchases"), 
                                   value = 0, 
                                   step  = 500, 
                                   min   = 0),
                      bsTooltip("P2purchase", 
                                IB$P2purchase, 
                                placement = "right", 
                                options   = list(container = "body"))),
               column(6, 
                      radioButtons("TypePurchase", 
                                   label   = NULL, 
                                   inline  = FALSE,  
                                   choices = Purchase.list),
                      bsTooltip("TypePurchase", 
                                IB$TypePurchase, 
                                placement = "right", 
                                options   = list(container = "body")), 
                      style = "margin-top: 20px;")),
             
             hr(),
             
             # Pillar III  -------------------------------------------------------------
             fluidRow(
               tags$h4("Private Pension Fund - Pillar III"), 
               style = "margin-left: 1%;"),
             
             fluidRow(
               numericInput("CurrentP3", 
                            label = h5("Current assets"), 
                            value = 50000, 
                            step  = 1000, 
                            min   = 0, 
                            width = '94%'),
               bsTooltip("CurrentP3", 
                         IB$CurrentP3, 
                         placement = "right", 
                         options   = list(container = "body")),
               style = "margin-left: 1%;"),
             
             fluidRow(
               column(5, 
                      numericInput("P3purchase", 
                                   label = h5("Annual contribution"), 
                                   value = 0, 
                                   step  = 500, 
                                   min   = 0),
                      bsTooltip("P3purchase", 
                                IB$P3purchase, 
                                placement = "right", 
                                options   = list(container = "body")), 
                      style = "margin-left: 0.5%;margin-right: 5%;"),
               column(5, 
                      numericInput("returnP3", 
                                   label = h5("Expected Return %"), 
                                   value = BVGMindestzinssatz*100, 
                                   step  = 0.1, 
                                   min   = 0, 
                                   max   = 100),
                      bsTooltip("returnP3", 
                                IB$returnP3, 
                                placement = "right", 
                                options   = list(container = "body")),
                      style = "margin-left:9%;"))
             
      ), #end first column/side bar panel
      
      # Main Panel -------------------------------------------------------------
      
      column(8, 
             tabsetPanel(
               type = "pills",
               
               # Plot  ----------------------------------------------------------
               tabPanel(title = "Plot", 
                        value = "Plot", 
                        fluidRow(align = "center", 
                                 verbatimTextOutput("Totals")),
                        fluidRow(htmlOutput("plot1"),
                                 style = "margin-left: 5%;"),
                        fluidRow(htmlOutput("plot2"), 
                                 style = "margin-left: 15%;")#,
               ), # end tab Plot
               
               #Table
               tabPanel(title = "Table", 
                        value = "Table", 
                        div(style = 'width:800px; overflow-x: scroll',
                            htmlOutput("table"))
               ) # end tab Table
             ), # end tabsetPanel
             
             # Footer Main Panel  ----------------------------------------------------
             #Disclaimer
             fluidRow(align = "left", 
                      verbatimTextOutput("disclaimer")),
             
             # Download
             fluidRow(align = "left", 
                      #Add button to download report
                      downloadButton("report", "Generate report"),
                      style = "margin-left: 8.5%;")
      ) #end second column/main panel
    ), #end of FluidRow
    
    hr(),
    
    # Footer  -------------------------------------------------------------
    
    fluidRow(
      column(9, 
             id  ="git", 
             a(href = "https://github.com/miraisolutions/SmaRP.git", 
               icon("github-square", "fa-2x"))),
      column(3, 
             a(href = "http://www.mirai-solutions.com", 
               img(src   = 'mirai.png', 
                   align = "right",
                   width = "40%")), 
             align ="right", 
             style = "margin-bottom: 1%;"),
      style = "margin-right:0.1%;")
  ) # end of fluidPage
) #end of shinyUI
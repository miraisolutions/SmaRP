# #FF9966 Mirai Orange
# #008cc3 Mirai blue
# #189bce background header
# #ea8b5b title orange

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
Sys.setlocale("LC_TIME", "C")

bsTooltip <- shinyBS::bsTooltip # info windows

# fluidPage UI
fluidPage(
  
  useShinydashboardPlus(),
  
  # Style  ----
  theme = "style.css",
  
  # Header  ----
  fluidRow(
    id = "head1",
    column(
      1,
      fluidRow(a(
        href = "https://github.com/miraisolutions/SmaRP.git",
        img(
          src = "SmaRPStiker.png",
          height = "90%",
          width = "90%"
        )
      ),
      style = "margin-top: 5%; margin-bottom: 5%; margin-left: 20%;"
      )
    ),
    column(
      2,
      fluidRow(h2("SmaRP")),
      fluidRow(h3("Smart Retirement Planning"))
    )
  ), # end of FluidRow / Header
  
  # Main  ----
  fluidRow(
    # Sidebar  ----
    column(
      5,
      # Personal Info  ----
      fluidRow(
        tags$h4("Personal Info"),
        style = "margin-left: 10%;"
      ),
      
      # Birthdate and gender
      fluidRow(
        fluidRow(
          id = "head2",
          column(
            5,
            dateInput("Birthdate",
                      label = h5("Birthdate"),
                      value = "1980-12-30",
                      format = "dd-mm-yyyy"
            ),
            bsTooltip("Birthdate",
                      IB$Birthdate,
                      placement = "center",
                      options = list(container = "body")
            )
          ),
          column(2),
          column(
            5,
            conditionalPanel(
              condition = 'input.provideRetirementAge==""',
              fluidRow(
                radioButtons("genre",
                             label = h5("Gender affiliation"),
                             inline = TRUE,
                             choices = list("Male" = "M", "Female" = "F"),
                             selected = "M"
                )
              )
            ),
            style = "margin-left: 8%;"
          )
        ), # end fluidRow
        
        # Desired retirement age conditional panel
        fluidRow(
          id = "head2",
          checkboxInput(
            "provideRetirementAge",
            "Desired Retirement Age (optional)",
            FALSE,
            width = '300px'
          ),
          bsTooltip("provideRetirementAge",
                    IB$RetirementAgeOptional,
                    placement = "right",
                    options = list(container = "body")
          ),
          uiOutput("conditionalRetirementAge"),
          bsTooltip("conditionalRetirementAge",
                    IB$RetirementAge,
                    placement = "right",
                    options = list(container = "body")
          ),
          style = "margin-left: 0%;"
        ),
        
        # PLZ 
        fluidRow(
          id = "head2",
          column(
            5,
            selectInput("postalcode",
                        label = h5("Postal Code"),
                        choices = PLZvec,
                        selected = "8001"
            )
          ),
          column(1),
          column(
            3,
            selectInput("gemeinden",
                        label = h5("Gemeinden"),
                        choices = GDENAMEvec,
                        selected = "Zürich"
            )
          )
        ),
        
        
        # Rate Group and number of children
        fluidRow(
          id = "head2",
          column(
            6,
            radioButtons("rate_group",
                         label = h5("Marital Status"),
                         inline = TRUE,
                         choices = Rate_group.list,
                         selected = "A"
            ),
            bsTooltip("rate_group",
                      IB$rate_group,
                      placement = "center",
                      options = list(container = "body")
            )
          ),
          column(
            5,
            numericInput("NKids",
                         label = h5("# Children"),
                         value = 0,
                         min = 0,
                         max = 9
            ),
            bsTooltip("NKids",
                      IB$NKids,
                      placement = "right",
                      options = list(container = "body")
            )
          ) # end column
        ), # end fluidRow
        
        # Church tax 
        fluidRow(
          id = "head2",
          radioButtons("churchtax",
                       label = h5("Church affiliation"),
                       inline = TRUE,
                       choices = church_tax.list,
                       selected = "A"
          ),
          style = "margin-left: 0%;"
        ),
        style = "margin-left: 10%;"
      ), # end of inital fluidRow
      
      hr(),
      
      
      # Pillar II  -------
      fluidRow(
        id = "head2",
        boxPlus(
          title = tags$h4("Occupational Pension Fund - Pillar II"),
          status = "warning",
          collapsible = TRUE,
          collapsed = TRUE,
          width = 8,
          closable = FALSE,
          dropdown_icon = NULL,
          enable_dropdown = TRUE,
          sidebarLayout(
            column(5,
                   numericInput("Salary",
                                label = h5("Current Annual Salary"),
                                value = 100000,
                                step = 1000,
                                min = 0
                   ),
                   bsTooltip("Salary",
                             IB$Salary,
                             placement = "right",
                             options = list(container = "body")
                   ),
                   numericInput("SalaryGrowthRate",
                                label = h5("Expected Salary Growth Rate %"),
                                value = 0.5,
                                step = 0.1,
                                min = 0,
                                max = 100
                   ),
                   bsTooltip("SalaryGrowthRate",
                             IB$SalaryGrowthRate,
                             placement = "right",
                             options = list(container = "body")
                   )
            ),
            column(5,
                   numericInput("CurrentP2",
                                label = h5("Current BVG assets"),
                                value = 100000,
                                step = 1000,
                                min = 0
                   ),
                   bsTooltip("CurrentP2",
                             IB$CurrentP2,
                             placement = "right",
                             options = list(container = "body")
                   ),
                   numericInput("P2interestRate",
                                label = h5("Interest Rate % (optional)"),
                                value = 100 * BVGMindestzinssatz,
                                step = 1,
                                min = 100 * BVGMindestzinssatz,
                                max = 100
                   ),
                   bsTooltip("P2interestRate",
                             IB$P2interestRate,
                             placement = "right",
                             options = list(container = "body")
                   )
            )
          ),
          fluidRow(
            column(11,
                   numericInput("P2purchase",
                                label = h5("Voluntary purchases"),
                                value = 0,
                                step = 500,
                                min = 0
                   ),
                   bsTooltip("P2purchase",
                             IB$P2purchase,
                             placement = "right",
                             options = list(container = "body")
                   ),
                   radioButtons("TypePurchase",
                                label = NULL,
                                inline = FALSE,
                                choices = Purchase.list
                   ),
                   bsTooltip("TypePurchase",
                             IB$TypePurchase,
                             placement = "right",
                             options = list(container = "body")
                   ),
                   style = "margin-top: 20px;"
            )
          ) # end fluidRow
        ), # end boxPlus
        style = "margin-left: 10%;"
      ), # end fluidRow
      
      # Pillar III  -------
      fluidRow(
        id = "head2",
        boxPlus(
          title = tags$h4("Private Pension Fund - Pillar III"),
          status = "warning",
          collapsible = TRUE,
          collapsed = TRUE,
          width = 8,
          closable = FALSE,
          dropdown_icon = NULL,
          enable_dropdown = TRUE,
          fluidRow(
            column(11,
                   numericInput("CurrentP3",
                                label = h5("Current assets"),
                                value = 50000,
                                step = 1000,
                                min = 0
                   ),
                   bsTooltip("CurrentP3",
                             IB$CurrentP3,
                             placement = "right",
                             options = list(container = "body")
                   )
            )
          ),
          fluidRow(
            column(11,
                   numericInput("P3purchase",
                                label = h5("Annual contribution"),
                                value = 0,
                                step = 500,
                                min = 0
                   ),
                   bsTooltip("P3purchase",
                             IB$P3purchase,
                             placement = "right",
                             options = list(container = "body")
                   ),
                   numericInput("returnP3",
                                label = h5("Expected Return %"),
                                value = BVGMindestzinssatz * 100,
                                step = 0.1,
                                min = 0,
                                max = 100
                   ),
                   bsTooltip("returnP3",
                             IB$returnP3,
                             placement = "right",
                             options = list(container = "body")
                   )
            )
          ) # end fluidRow
        ), # end boxPlus
        style = "margin-left: 10%;"
      ) # end fluidRow
    ), # end first column/side bar panel
    
    # second column / Main Panel -------
    column(
      7,
      fluidRow(
        tabsetPanel(
          # type = "pills",
          
          # Plot  ----
          tabPanel(
            title = "Plot",
            value = "Plot",
            fluidRow(
              verbatimTextOutput("Totals")
            ),
            fluidRow(
              htmlOutput("plot1")
            ),
            fluidRow(
              htmlOutput("plot2")
            ) 
          ), # end tabPanel Plot
          
          # Table
          tabPanel(
            title = "Table",
            value = "Table",
            div(
              style = "width:800px; overflow-x: scroll",
              htmlOutput("table")
            )
          ) # end tabPanel Table
        ) # end tabsetPanel
      ), # end fluidRow
      
      fluidRow(
        align = "left", 
        # Add button to download report
        downloadButton("report", "Generate report"),
        style = "margin-top: 5%; margin-left: 5%;"
      ) # end of FluidRow
    ) # end second column/main panel
  ), # end fluidRow
  
  # Disclaimer
  fluidRow(
    verbatimTextOutput("disclaimer")
  ),
  
  hr(),
  
  # Footer  ----
  fluidRow(
    column(9,
           id = "git",
           a(
             href = "https://github.com/miraisolutions/SmaRP.git",
             icon("github-square", "fa-2x")
           )
    ),
    column(3,
           a(
             href = "http://www.mirai-solutions.com",
             img(
               src = "mirai.png",
               align = "right",
               width = "40%"
             )
           ),
           align = "right",
           style = "margin-bottom: 1%;"
    ),
    style = "margin-right: 0.1%;"
  )
) # end of fluidPage

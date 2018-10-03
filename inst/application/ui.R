# #FF9966 Mirai Orange
# #008cc3 Mirai blue
# #189bce background header
# #ea8b5b title orange

Sys.setlocale("LC_TIME", "C")

bsTooltip <- shinyBS::bsTooltip # info windows
boxPlus <- shinydashboardPlus::boxPlus

# fluidPage UI
fluidPage(

  shinyWidgets::useShinydashboardPlus(),

  # Style  ----
  theme = "style.css",

  # Header  ----
  fluidRow(
    id = "header",
    a(
      href = "https://github.com/miraisolutions/SmaRP.git",
      target = "_blank",
      img(
        id = "sticker-header",
        src = "SmaRPSticker.png",
        height = "100px"

      )
    ),
    h2("SmaRP"),
    h3("Smart Retirement Planning")
  ), # end Header fluidRow

  # Main  ----
  div(
    id = "main",

    fluidRow(

      # Sidebar  ----
      column(
        4,

        # Personal Info  ----
        fluidRow(
          boxPlus(
            title = "Personal Info",
            status = "primary",
            collapsible = TRUE,
            width = 12,
            closable = FALSE,
            dropdown_icon = NULL,
            enable_dropdown = TRUE,

            # > Birthdate and gender ----
            fluidRow(
              column(
                6,
                dateInput("Birthdate",
                          label = "Birthdate",
                          value = "1980-12-30",
                          format = "dd-mm-yyyy"
                ),
                bsTooltip("Birthdate",
                          IB$Birthdate,
                          placement = "center",
                          options = list(container = "body")
                )
              ),
              column(
                6,
                conditionalPanel(
                  condition = '!input.provideRetirementAge',
                  radioButtons("genre",
                               label = "Gender Affiliation",
                               inline = TRUE,
                               choices = list("Male" = "M", "Female" = "F"),
                               selected = "M"
                  )
                )
              )
            ),

            # > Desired retirement age conditional panel ----
            fluidRow(
              column(
                6,
                checkboxInput(
                  "provideRetirementAge",
                  "Desired Retirement Age (optional)",
                  FALSE
                ),
                bsTooltip("provideRetirementAge",
                          IB$RetirementAgeOptional,
                          placement = "right",
                          options = list(container = "body")
                )
              ),
              column(
                6,
                # > Conditional Retirement age input ----
                conditionalPanel(
                  condition = 'input.provideRetirementAge',
                  numericInput(
                    "RetirementAge",
                    label = NULL, # "Desired Retirement Age",
                    value = 65,
                    step = 1,
                    min = 55,
                    max = 70
                  )
                ),
                bsTooltip("RetirementAge",
                          IB$RetirementAge,
                          placement = "right",
                          options = list(container = "body")
                )
              )
            ),

            # > PLZ / Gemeinde ----
            fluidRow(
              id = "head2",
              column(
                6,
                selectInput("postalcode",
                            label = "Postal Code",
                            choices = PLZvec,
                            selected = "8001"
                )
              ),
              column(
                6,
                selectInput("gemeinden",
                            label = "Municipality",
                            choices = GDENAMEvec,
                            selected = "Zürich"
                )
              )
            ),

            # > Rate Group and number of children ----
            fluidRow(
              column(
                6,
                radioButtons("rate_group",
                             label = "Marital Status",
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
                6,
                numericInput("NKids",
                             label = "# Children",
                             value = 0,
                             min = 0,
                             max = 9
                ),
                bsTooltip("NKids",
                          IB$NKids,
                          placement = "right",
                          options = list(container = "body")
                )
              )
            ),

            # > Church tax ----
            fluidRow(
              column(
                12,
                radioButtons("churchtax",
                             label = "Church Affiliation",
                             inline = TRUE,
                             choices = church_tax.list,
                             selected = "A"
                )
              )
            ),

            NULL

          ) # end Personal Info boxPlus
        ), # end  Personal Info fluidRow


        # Pillar II  -------
        fluidRow(
          boxPlus(
            title = "Occupational Pension Fund - Pillar II",
            status = "primary",
            collapsible = TRUE,
            collapsed = TRUE,
            width = 12,
            closable = FALSE,
            dropdown_icon = NULL,
            enable_dropdown = TRUE,
            fluidRow(
              column(
                6,
                numericInput("Salary",
                             label = "Current Annual Salary",
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
                             label = "Expected Salary Growth Rate %",
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
              column(
                6,
                numericInput("CurrentP2",
                             label = "Current BVG Assets",
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
                             label = "Interest Rate % (optional)",
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
              column(
                6,
                numericInput("P2purchase",
                             label = "Voluntary Purchases",
                             value = 0,
                             step = 500,
                             min = 0
                ),
                bsTooltip("P2purchase",
                          IB$P2purchase,
                          placement = "right",
                          options = list(container = "body")
                )
              ),
              column(
                6,
                radioButtons("TypePurchase",
                             label = br(), # empty placeholder for alignment
                             inline = TRUE,
                             choices = Purchase.list
                ),
                bsTooltip("TypePurchase",
                          IB$TypePurchase,
                          placement = "right",
                          options = list(container = "body")
                )
              )
            ) # end fluidRow
          ) # end boxPlus
        ), # end fluidRow

        # Pillar III  -------
        fluidRow(
          boxPlus(
            title = "Private Pension Fund - Pillar III",
            status = "primary",
            collapsible = TRUE,
            collapsed = TRUE,
            width = 12,
            closable = FALSE,
            dropdown_icon = NULL,
            enable_dropdown = TRUE,
            fluidRow(
              column(
                12,
                numericInput("CurrentP3",
                             label = "Current Assets",
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
              column(
                12,
                numericInput("P3purchase",
                             label = "Annual Contribution",
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
                             label = "Expected Return %",
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
            )
          ) # end Pillar III boxPlus
        ), # end Pillar III fluidRow

        NULL

      ), # end first Sidebar column

      # Main Panel -----
      column(
        8,

        fluidRow(
          column(
            12,
            tabsetPanel(

              # > Plot  ----
              tabPanel(
                title = "Plot",
                value = "Plot",
                verticalLayout(
                  verbatimTextOutput("Totals"),
                  htmlOutput("plot1"),
                  htmlOutput("plot2")
                )
              ), # end tabPanel Plot

              # > Table ----
              tabPanel(
                title = "Table",
                value = "Table",
                div(
                  style = "width:800px; overflow-x: scroll",
                  htmlOutput("table")
                )
              ) # end tabPanel Table
            ) # end tabsetPanel
          ) # end column
        ), # end fluidRow

        br(),

        fluidRow(
          column(
            12,
            # Add button to download report
            downloadButton("report", "Generate report",
                           class = "btn-smarp")
          )
        ), # end FluidRow

        NULL

      ) # end Main Panel column

    ), # end fluidRow

    # Disclaimer
    fluidRow(
      verbatimTextOutput("disclaimer")
    )
  ),
  # Footer  ----
  fluidRow(
    id = "footer",

    a(
      id = "git-footer",
      href = "https://github.com/miraisolutions/SmaRP.git",
      target = "_blank",
      icon("github-square", "fa-2x")
    ),
    a(
      href = "http://www.mirai-solutions.com",
      target = "_blank",
      img(
        id = "mirai-footer",
        src = "mirai.png",
        align = "right",
        height = "100px"
      )
    )
  )
) # end of fluidPage

# #FF9966 Mirai Orange
# #008cc3 Mirai blue
# #189bce background header
# #ea8b5b title orange

Sys.setlocale("LC_TIME", "C")

bs_embed_tooltip <- bsplus::bs_embed_tooltip # info windows
boxPlus <- shinydashboardPlus::boxPlus

# fluidPage UI
fluidPage(

  tags$head(
    tags$script(
      type = "text/javascript",
      src = "https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.6.3/iframeResizer.contentWindow.min.js"
    )
  ),

  shinyWidgets::useShinydashboardPlus(),

  # indirectly covered by the above (shinydashboard -> bootstrap), but should
  # stay for clarity and cleanliness!
  tags$head(bsplus::use_bs_tooltip()),

  # Style  ----
  theme = "style.css",

  # Pop up before leaving page ----
  tags$script('window.onbeforeunload = function(event) {return "";};'),

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
    div(id = "title", h2("SmaRP"), span(id = "version", get_SmaRP_version())),
    div(id = "subtitle", h3("Smart Retirement Planning"))

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
                          value = value$birthday,
                          format = "dd-mm-yyyy"
                ) %>%
                  bs_embed_tooltip(title = IB$Birthdate, placement = "right")
              ),
              column(
                6,
                radioButtons("gender",
                             label = "Gender Affiliation",
                             inline = TRUE,
                             choices = list("Male" = "M", "Female" = "F"),
                             selected = value$gender
                )
              )
            ),

            # > Desired retirement age conditional panel ----
            fluidRow(
              column(
                6,
                checkboxInput(
                  "provideRetirementAge",
                  span("Desired Retirement Age (optional)") %>%
                    bs_embed_tooltip(title = IB$RetirementAgeOptional, placement = "right"),
                  FALSE
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
                    value = value$retirement,
                    step = 1,
                    min = value$min_retirement,
                    max = value$max_retirement
                  ) %>%
                    bs_embed_tooltip(title = IB$RetirementAge, placement = "right")
                )
              )
            ),

            # > PLZ / Gemeinde ----
            fluidRow(
              column(
                12,
                selectInput("plzgemeinden",
                            label = h5("Postal Code / Municipality"),
                            choices = PLZGemeinden$PLZGDENAME,
                            selected = value$plz
                )
              )
            ),

            # > Rate Group and number of children ----
            fluidRow(
              column(
                6,
                radioButtons("rate_group",
                             label = span("Marital Status") %>%
                               bs_embed_tooltip(title = IB$rate_group, placement = "right"),
                             inline = TRUE,
                             choices = Rate_group.list,
                             selected = value$rate
                )
              ),
              column(
                6,
                numericInput("NChildren",
                             label = "# Children",
                             value = value$children,
                             min = 0,
                             max = value$max_children
                ) %>%
                  bs_embed_tooltip(title = IB$NChildren, placement = "right")
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
                             selected = value$church
                )
              )
            ),

            NULL

          ) # end Personal Info boxPlus
        ), # end  Personal Info fluidRow


        # 2nd Pillar  -------
        fluidRow(
          boxPlus(
            title = "Occupational Fund - Second Pillar",
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
                             value = value$salary,
                             step = 1000,
                             min = 0
                ) %>%
                  bs_embed_tooltip(title = IB$Salary, placement = "right"),
                numericInput("SalaryGrowthRate",
                             label = "Expected Salary Growth Rate %",
                             value = value$growth_rate,
                             step = 0.1,
                             min = 0,
                             max = value$max_growth_rate
                ) %>%
                  bs_embed_tooltip(title = IB$SalaryGrowthRate, placement = "right")
              ),
              column(
                6,
                numericInput("CurrentP2",
                             label = "Current BVG Assets",
                             value = value$p2,
                             step = 1000,
                             min = 0
                ) %>%
                  bs_embed_tooltip(title = IB$CurrentP2, placement = "right"),
                numericInput("P2interestRate",
                             label = "Interest Rate % (optional)",
                             value = value$p2_interest,
                             step = 1,
                             min = value$min_p2_interest,
                             max = value$max_p2_interest
                ) %>%
                  bs_embed_tooltip(title = IB$P2interestRate, placement = "right")
              )
            ),
            fluidRow(
              column(
                6,
                numericInput("P2purchase",
                             label = "Voluntary Purchases",
                             value = value$p2_voluntary,
                             step = 500,
                             min = 0
                ) %>%
                  bs_embed_tooltip(title = IB$P2purchase, placement = "right")
              ),
              column(
                6,
                radioButtons("TypePurchase",
                             label = span("Purchase Type") %>%
                               bs_embed_tooltip(title = IB$TypePurchase, placement = "right"),
                             inline = TRUE,
                             choices = Purchase.list
                )
              )
            ) # end fluidRow
          ) # end boxPlus
        ), # end fluidRow

        # 3rd Pillar -------
        fluidRow(
          boxPlus(
            title = "Private Fund - Third Pillar",
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
                             value = value$p3,
                             step = 1000,
                             min = 0
                ) %>%
                  bs_embed_tooltip(title = IB$CurrentP3, placement = "right")
              )
            ),
            fluidRow(
              column(
                12,
                numericInput("P3purchase",
                             label = "Annual Contribution",
                             value = value$p3_annual,
                             step = 500,
                             min = 0
                ) %>%
                  bs_embed_tooltip(title = IB$P3purchase, placement = "right"),
                numericInput("returnP3",
                             label = "Expected Return %",
                             value = value$p3_return,
                             step = 0.1,
                             min = 0,
                             max = value$max_p3_return
                ) %>%
                  bs_embed_tooltip(title = IB$returnP3, placement = "right")
              )
            )
          ) # end of 3rd Pillar boxPlus
        ), # end of 3rd Pillar fluidRow

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
                  htmlOutput("plot_t"),
                  htmlOutput("plot_final"),
                  br(),
                  # Add button to download report
                  downloadButton("report", span("Generate report") %>%
                                   bs_embed_tooltip(title = IB$GenerateReport, placement = "right"),
                                 class = "btn-smarp")
                )
              ), # end tabPanel Plot

              # > Table ----
              tabPanel(
                title = "Table",
                value = "Table",
                verticalLayout(
                  htmlOutput(
                    "table"
                  ),
                  br(),
                  # Add button to download report
                  downloadButton("data_download", "Download Data",
                                 class = "btn-smarp")
                )
              ) # end tabPanel Table
            ) # end tabsetPanel
          ) # end column
        ), # end fluidRowm

        NULL

      ) # end Main Panel column

    ), # end fluidRow

    # Disclaimer
    fluidRow(
      # Disclaimer ----
      column(
        8, offset = 4,
        div(id = "disclaimer",
            HTML(
              "<b>Disclaimer</b>", "<br>",
              "The content of the report does not hold any legal value and its correctness is not guaranteed.", "<br>",
              "Mirai Solutions GmbH does not store any information provided while using SmaRP."
            )
        )
      )
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

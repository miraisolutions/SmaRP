suppressPackageStartupMessages(library(googleVis))
#library(rmarkdown)
library(dplyr, warn.conflicts = FALSE)
library(magrittr)

options(shiny.sanitize.errors = TRUE)

function(input, output, session) {
  # Validate inputs and set defaults ----
  
  # Birthday
  Birthdate <- reactive({
    validate(need(input$Birthdate, VM$Birthdate))
    validate(need((input$Birthdate - 65) > 0, VM$Birthdate2))
    input$Birthdate
  })
  
  # Gender
  genre <- reactive({
    validate(need(input$genre, VM$genre))
    input$genre
  })
  
  # Mirai Colors
  miraiColors <- reactive({
    "['#008cc3', '#FF9966', '#13991c']"
  })
  
  # Retirement Age
  RetirementAge <- reactive({
    if (input$provideRetirementAge) {
      validate(need(input$RetirementAge, VM$RetirementAge))
      min(70, input$RetirementAge)
    } else {
      if (genre() == "M") {
        MRetirementAge
      } else {
        FRetirementAge
      }
    }
  })
  
  # Pillar III ----
  # defaut option 0
  CurrentP3_notZero <- reactive({
    isnotAvailableReturnZero(input$CurrentP3)
  })
  
  CurrentP3 <- reactive({
    if (P3purchase() == 0 &
        Salary() == 0 & CurrentP2() == 0 & P2purchase() == 0) {
      validate(
        need_not_zero(
          CurrentP3_notZero(),
          VM$CurrentP3_CurrentP2_Salary_Purchases_notZero
        )
      )
      CurrentP3_notZero()
    } else {
      CurrentP3_notZero()
    }
  })
  
  P3purchase <- reactive({
    isnotAvailableReturnZero(input$P3purchase)
  })
  
  returnP3_notzero <- reactive({
    isnotAvailableReturnZero(input$returnP3 / 100)
  })
  
  returnP3 <- reactive({
    if (CurrentP3() == 0 &
        P3purchase() == 0 &
        Salary() == 0 & CurrentP2() == 0 & P2purchase() == 0) {
      validate(
        need_not_zero(
          returnP3_notzero(),
          VM$CurrentP3_CurrentP2_Salary_Purchases_notZero
        )
      )
      returnP3_notzero()
    } else {
      returnP3_notzero()
    }
  })
  
  
  # Tax info ----
  TaxRelief <- reactive({
    if (input$rate_group == "C") {
      MaxContrTax * 2
    } else {
      MaxContrTax
    }
  })
  
  # Postal Code --> Gemeinden
  
  postalcode <- reactive({
    validate(need(input$postalcode, VM$postalcode))
    input$postalcode
  })
  
  observe({
    y <- which(PLZGemeinden$PLZ == input$postalcode)
    z <- PLZGemeinden$GDENAME[y]
    updateSelectInput(session, "gemeinden", selected = z)
    
  })
  
  # Gemeinden --> Postal Code
  
  gemeinden <- reactive({
    validate(need(input$gemeinden, VM$gemeinden))
    input$gemeinden
  })
  
  observe({
    b <- which(PLZGemeinden$GDENAME == gemeinden())
    if (length(b) > 1) {
      c <- PLZGemeinden$PLZ[b][1]
    } else {
      c <- PLZGemeinden$PLZ[b]
    }
    updateSelectInput(session, "postalcode", selected = c)
    
  })
  
  # Number of kids (max = 9)
  NKids <- reactive({
    min(isnotAvailableReturnZero(input$NKids), 9)
  })
  
  # Tariff
  rate_group <- reactive({
    validate(need(input$rate_group, VM$rate_group))
    input$rate_group
  })
  
  # Church taxes
  churchtax <- reactive({
    if (input$churchtax == TRUE) {
      "Y"
    } else {
      "N"
    }
  })
  
  # Salary
  Salary <- reactive({
    validate(need(input$Salary, VM$Salary))
    input$Salary
  })
  
  SalaryGrowthRate <- reactive({
    isnotAvailableReturnZero(input$SalaryGrowthRate / 100)
  })
  
  # Pillar II
  CurrentP2 <- reactive({
    isnotAvailableReturnZero(input$CurrentP2)
  })
  
  P2interestRate <- reactive({
    if (isnotAvailable(input$P2interestRate)) {
      BVGMindestzinssatz
    } else {
      input$P2interestRate / 100
    }
  })
  
  P2purchase <- reactive({
    isnotAvailableReturnZero(input$P2purchase)
  })
  
  TypePurchase <- reactive({
    validate(need(input$TypePurchase, VM$TypePurchase))
    input$TypePurchase
  })
  
  
  # calc P2 fund ----
  ContributionP2Path <- reactive({
    buildContributionP2Path(
      birthday = Birthdate(),
      Salary = Salary(),
      SalaryGrowthRate = SalaryGrowthRate(),
      CurrentP2 = CurrentP2(),
      P2purchase = P2purchase(),
      TypePurchase = TypePurchase(),
      rate = P2interestRate(),
      givenday = lubridate::today("UTC"),
      RetirementAge = RetirementAge()
    )
  })
  
  # calc P3 fund ----
  ContributionP3path <- reactive({
    buildContributionP3path(
      birthday = Birthdate(),
      P3purchase = P3purchase(),
      CurrentP3 = CurrentP3(),
      returnP3 = returnP3(),
      RetirementAge = RetirementAge()
    )
  })
  
  # calc Tax benefits ----
  ContributionTaxpath <- reactive({
    buildTaxBenefits(
      birthday = Birthdate(),
      TypePurchase = TypePurchase(),
      P2purchase = P2purchase(),
      P3purchase = P3purchase(),
      returnP3 = returnP3(),
      Salary = Salary(),
      SalaryGrowthRate = SalaryGrowthRate(),
      postalcode = postalcode(),
      NKids = NKids(),
      churchtax = churchtax(),
      rate_group = rate_group(),
      givenday = lubridate::today("UTC"),
      RetirementAge = RetirementAge()
    )
  })
  
  # build Road2Retirement ----
  Road2Retirement <- reactive({
    ContributionP2Path() %>%
      left_join(ContributionP3path(), by = c("calendar", "t")) %>%
      left_join(ContributionTaxpath(), by = c("calendar", "t")) %>%
      mutate(Total = TotalP2 + TotalP3 + TotalTax)
  })
  
  # Table ----
  output$table <- renderTable({
    makeTable(Road2Retirement = Road2Retirement())
  }, digits = 0)
  
  
  # T series plot ----
  TserieGraphData <- reactive({
    Road2Retirement() %>%
      mutate(TaxBenefits = TotalTax) %>%
      mutate(OccupationalPension = DirectP2 + ReturnP2) %>%
      mutate(PrivatePension = DirectP3 + ReturnP3) %>%
      select(calendar,
             OccupationalPension,
             PrivatePension,
             TaxBenefits) %>%
      .[, colSums(. != 0, na.rm = TRUE) > 0]
  })
  
  output$plot1 <- renderGvis({
    gvisAreaChart(
      chartid = "plot1",
      data = TserieGraphData(),
      xvar = "calendar",
      yvar = colnames(TserieGraphData())[which(colnames(TserieGraphData()) != "calendar")],
      options = list(
        width = 800,
        height = 400,
        isStacked = TRUE,
        legend = "bottom",
        colors = miraiColors()
      )
    )
  })
  
  # Bar plot -----
  FotoFinish <- reactive({
    Road2Retirement() %>%
      mutate(TaxBenefits = TotalTax) %>%
      mutate(OccupationalPension = DirectP2 + ReturnP2) %>%
      mutate(PrivatePension = DirectP3 + ReturnP3) %>%
      select(OccupationalPension, PrivatePension, TaxBenefits) %>%
      tail(1) %>%
      prop.table() %>%
      select_if(function(x)
        x != 0)
  })
  
  
  BarGraphData <- reactive({
    cbind(FotoFinish(), FotoFinish()) %>%
      set_colnames(c(colnames(FotoFinish()), paste0(
        colnames(FotoFinish()), ".annotation"
      ))) %>%
      mutate(contribution = "") %>%
      changeToPercentage() %>%
      .[, order(colnames(.))]
  })
  
  output$plot2 <- renderGvis({
    gvisBarChart(
      chartid = "plot2",
      data = BarGraphData(),
      xvar = "contribution",
      yvar = colnames(BarGraphData())[!grepl("contribution", colnames(BarGraphData()))],
      options = list(
        width = 600,
        height = 130,
        isStacked = TRUE,
        vAxes = "[{minValue:0}]",
        legend = "none",
        colors = miraiColors(),
        opacity = 0.3,
        hAxis = "{format:'#,###%'}"
      )
    )
  })
  
  # build Totals statement ----
  retirementdate <- reactive({
    getRetirementday(Birthdate(), RetirementAge())
  })
  
  retirementfund <- reactive({
    Road2Retirement()[, "Total"] %>%
      tail(1) %>%
      as.integer()
  })
  
  lastSalary <- reactive({
    Road2Retirement()[, "ExpectedSalaryPath"] %>%
      tail(1) %>%
      as.integer()
  })
  
  percentageLastSalary <- reactive({
    if (lastSalary() != 0) {
      numTimes <- retirementfund() / lastSalary()
      numTimes %<>% formatC(format = "f", digits = 2)
      paste0("which is ", numTimes, " times your last salary")
    } else {
      ""
    }
  })
  
  output$Totals <- renderText({
    paste(
      "Total retirement fund as of",
      format(retirementdate(), "%d-%m-%Y"),
      "is",
      formatC(
        retirementfund() / 1000,
        format = "f",
        big.mark = ",",
        digits = 0,
        decimal.mark = "."
      ),
      "k,",
      percentageLastSalary(),
      sep = " "
    )
  })
  
  
  # Disclaimer ----
  output$disclaimer <- renderText({
    paste(
      "Disclaimer:",
      "The results of these calculations do not have any legal value.",
      "To check the details of the calculations, parameters and assumptions, please download the report.",
      sep = "\n"
    )
  })
  
  # Output Report ----
  
  # params list to be passed to the output
  params <- reactive(
    list(
      Salary = Salary(),
      birthday = Birthdate(),
      Road2Retirement = Road2Retirement(),
      SalaryGrowthRate = SalaryGrowthRate(),
      CurrentP2 = CurrentP2(),
      P2purchase = P2purchase(),
      TypePurchase = TypePurchase(),
      rate = P2interestRate(),
      P3purchase = P3purchase(),
      CurrentP3 = CurrentP3(),
      returnP3 = returnP3(),
      postalcode = postalcode(),
      Kanton = returnPLZKanton(postalcode()),
      NKids = NKids(),
      churchtax = churchtax(),
      rate_group = rate_group(),
      MaxContrTax = TaxRelief(),
      retirementdate = retirementdate(),
      BarGraphData = BarGraphData(),
      TserieGraphData = TserieGraphData(),
      RetirementAge = RetirementAge(),
      TaxRate = NULL,
      retirementfund = retirementfund(),
      percentageLastSalary = percentageLastSalary(),
      PLZGemeinden = PLZGemeinden,
      AHL = AHL,
      ALV = ALV,
      VersicherungsL = VersicherungsL,
      VersicherungsV = VersicherungsV,
      VersicherungsK = VersicherungsK,
      DOV = DOV,
      Kinder = Kinder,
      Verheiratet = Verheiratet
    )
  )
  
  
  
  # output report
  output$report <- downloadHandler(
    filename = "report.pdf",
    content = function(file) {
      output <- rmarkdown::render(
        input = "report.Rmd",
        output_file = "report.pdf",
        output_format = "pdf_document",
        #        output_format = "html_document",
        params = params()
      )
      file.copy(output, file)
    }
  ) # end of downloadHandler
  
  # refresh inputs ----
  # Refresh plz-gemeinde correspondance
  # when the value of input$refreshButton becomes out of date
  # (i.e., when the button is pressed)
  refreshText <- eventReactive(input$refreshButton, {
    downloadInputs(refresh = TRUE)
  })
  
  output$refreshText <- renderText({
    paste(as.character(refreshText()))
  })
  
  
  # Conditional Retirement age input ----
  output$conditionalRetirementAge <- renderUI({
    if (input$provideRetirementAge) {
      numericInput(
        "RetirementAge",
        label = h5("Desired Retirement Age"),
        value = 65,
        step = 1,
        min = 55,
        max = 70
      )
    }
  })
}

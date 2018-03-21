#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(lubridate)
library(dplyr)
library(magrittr)
library(googleVis)
library(rmarkdown)
library(shinyBS) # needed for the info windows
#library(shinyjs) #needed for hiding inputs 
#library(ggplot2)

# source core methodology and global variables
source("core.R")


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  Inputcase <- reactive({
    input$case
  })

  # validate inputs and set defaults ----
  Birthdate <- reactive({
    validate(
      need(input$Birthdate, 'Birthdate is a mandatory input')
    )
    input$Birthdate
    })
  
  RetirementAge <- reactive({
    if(input$provideRetirementAge){
      validate(
        need(input$RetirementAge, 'Please provide the desired retirement age')
        )
      input$RetirementAge
    } else if(Inputcase() == "General"){
      65
     } else {
      if (genre()=="M"){
        MRetirementAge
      } else {
        FRetirementAge
      }
    }
    })
  
  CurrentP3_notZero <- reactive({ 
    isnotAvailableReturnZero(input$CurrentP3)})
  
  CurrentP3 <-reactive({
    if (Inputcase() == "General") {
      validate(
        need_not_zero(CurrentP3_notZero(), "Pillar III value")
      )
      CurrentP3_notZero()
    } else {
      CurrentP3_notZero()
    }
  })

  P3purchase <- reactive({isnotAvailableReturnZero(input$P3purchase)})
  
  returnP3_notzero <- reactive({isnotAvailableReturnZero(input$returnP3)})
  returnP3 <- reactive({
    if (Inputcase() == "General") {
      validate(
        need_not_zero(returnP3_notzero(), "Pillar III Return")
      )
      returnP3_notzero()
    } else{
      returnP3_notzero()
    }
  })

  TaxRelief <- reactive({ 
    if(Inputcase() == "General"){
      isnotAvailableReturnZero(input$TaxRelief)
    }
    else{
      MaxContrTax
    }
    }) 
  
  currency <- reactive(
    if(Inputcase() == "General"){
      validate(
        need(input$currency, "Please provide a valid currency")
      )
      input$currency
    } else{
      "CHF"
    }
  )
  
  postalcode <- reactive({
    if(Inputcase() == "Swiss" & isnotAvailable(input$provideTaxRateSwiss)){
      validate(
        need(input$postalcode, "Please provide a valid postalcode")
      )
      input$postalcode
    }else{
     8001 
    }
  })
  
  NKids_notzero <- reactive({  isnotAvailableReturnZero(input$NKids)  })
  NKids <- reactive({
    if(NKids_notzero() >5){
      5
    }else{
      NKids_notzero()
    }
  })
  
  genre <- reactive({
    if(Inputcase() == "Swiss" & isnotAvailable(input$provideRetirementAge)){
      validate(
        need(input$genre, "Please provide your genre")
      )
      input$genre
    } else {
      "M"
    }
  })
  
  
  rate_group <- reactive({
    if(Inputcase() == "Swiss" & isnotAvailable(input$provideTaxRateSwiss)){
      validate(
        need(input$rate_group, "Please provide a valid civil status")
      )
      input$rate_group
    } else{
      "A"
    }
  })
  
  churchtax <- reactive(({
    if(Inputcase() == "Swiss" & isnotAvailable(input$provideTaxRateSwiss)){
      validate(
        need(input$churchtax, "Please provide a valid religous status")
      )
      input$churchtax
    } else {
      "N"
    }
  }))
  
  Salary <- reactive({ 
    #isnotAvailableReturnZero(input$Salary)})
    if(Inputcase() == "Swiss"){
    validate(
      need(input$Salary, "Please provide a non zero Salary")
    )
    input$Salary}
    else if (Inputcase() == "General") {
      0}
  })

  
  SalaryGrowthRate <- reactive({ if(Inputcase() == "Swiss"){
      isnotAvailableReturnZero(input$SalaryGrowthRate)}
      else if (Inputcase() == "General"){
        0}
      })
  
  CurrentP2 <- reactive({ if(Inputcase() == "Swiss"){
    isnotAvailableReturnZero(input$CurrentP2)}
    else if (Inputcase() == "General"){
      0}
  })

  P2purchase <- reactive({ if(Inputcase() == "Swiss"){
    isnotAvailableReturnZero(input$P2purchase)}
    else if (Inputcase() == "General"){
      0}
  })
  
  TypePurchase <- reactive({
    if(Inputcase() =="Swiss"){
      validate(
        need(input$TypePurchase, "please provide a valid Pillar 2 Purchase Type")
      )
      input$TypePurchase
    } else {
      "SingleP2"
    }
  })
  
  
  # TaxRate ----
  taxRateValue <- reactive({
    if(Inputcase() == "General"){
      isnotAvailableReturnZero(input$TaxRate)
    } else if(Inputcase() == "Swiss" & input$provideTaxRateSwiss){
      validate(
        need(input$TaxRateSwiss, "Please provided the Tax Rate")
      )
      input$TaxRateSwiss
    } else{
      NULL
    }
  })
  
  
  # calc P2 fund ----
  ContributionP2Path <- reactive({ 
    buildContributionP2Path(birthday = Birthdate(),
                            Salary = Salary(), #ifelse(input$case == "General", 0, Salary()),
                            SalaryGrowthRate = SalaryGrowthRate(),
                            CurrentP2 = CurrentP2(), #ifelse(input$case == "General", 0, CurrentP2()),
                            P2purchase = P2purchase(),
                            TypePurchase = TypePurchase(),
                            rate = BVGMindestzinssatz,
                            givenday = today(),
                            RetirementAge = RetirementAge()
                            )
  })
  
  # calc P3 fund ----
  ContributionP3path <- reactive({
    buildContributionP3path(birthday = Birthdate(), 
                            P3purchase = P3purchase(), 
                            CurrentP3 = CurrentP3(), 
                            returnP3 = returnP3(),
                            RetirementAge = RetirementAge()
    )
  })
  
  # calc Tax benefits ----
  ContributionTaxpath <- reactive({
    buildTaxBenefits(birthday = Birthdate(), 
                     TypePurchase = TypePurchase(),
                     P2purchase = P2purchase(), 
                     P3purchase = P3purchase(), 
                     returnP3 = returnP3(),
                     Salary = Salary(), #ifelse(input$case == "General", 0, Salary()),
                     SalaryGrowthRate = SalaryGrowthRate(),
                     postalcode = postalcode(),
                     NKids = ifelse(isolate(input$NKids) >5, 5, isolate(input$NKids)),
                     churchtax = churchtax(),
                     rate_group = rate_group(),
                     MaxContrTax = TaxRelief(),
                     tax_rates_Kanton = tax_rates_Kanton,
                     BundessteueTabelle = BundessteueTabelle,
                     RetirementAge = RetirementAge(),
                     TaxRate = taxRateValue()
                     )
  })

  # build main df ----
  Road2Retirement <- reactive({
    ContributionP2Path() %>%
      left_join(ContributionP3path(), by = c("calendar", "t")) %>%
      left_join(ContributionTaxpath(), by = c("calendar", "t")) %>%
      mutate(Total = TotalP2 + TotalP3 + TotalTax)
  }) 
  
  # Table ----
  
  output$table <- renderTable({
    # Road2Retirement()[, c("calendar", "DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")] %>%
    #   mutate(calendar = paste(year(calendar), month(calendar, label = TRUE), sep = "-")) 
    makeTable(Road2Retirement = Road2Retirement(),
              currency = paste0( currency(), " "))
  }, digits = 0)
  
  
  # T series plot ----
  TserieGraphData <- reactive({
    Road2Retirement()[, c("calendar", "DirectP2", "DirectP3",  "DirectTax", "ReturnP2", "ReturnP3", "ReturnTax")] %>%
      .[, colSums(. != 0, na.rm = TRUE) > 0]
  })
  
  output$plot1 <- renderGvis({
    gvisAreaChart(
      chartid = "plot1",
      data = TserieGraphData(),
      xvar = "calendar",
      yvar = colnames(TserieGraphData()[,-1]),
      options = list(width = 700, height = 400, isStacked = TRUE, legend = "bottom")
    ) 
  })
  
  # bar plot -----
  FotoFinish <- reactive({
    Road2Retirement()[,c("DirectP2", "ReturnP2", "DirectP3", "ReturnP3", "DirectTax", "ReturnTax")]  %>% 
      tail(1) %>%
      prop.table() %>%
      select_if(function(x) x != 0)
  })
  
  
  BarGraphData <- reactive({
    cbind(FotoFinish(), FotoFinish()) %>%
      set_colnames(c(colnames(FotoFinish()), paste0(colnames(FotoFinish()), ".annotation"))) %>%
      mutate(contribution = "") %>%
      .[, order(colnames(.))]
  })
  
  output$plot2 <- renderGvis({
    gvisBarChart(
      chartid = "plot2",
      data = BarGraphData(),
      xvar = "contribution",
      yvar= colnames(BarGraphData())[!grepl("contribution", colnames(BarGraphData()))],
      options = list(width = 500, height = 130, isStacked = TRUE, vAxes = "[{minValue:0}]", legend = "none")
    )
  })
  
  # Totals ----
  retirementdate <- reactive({
    getRetirementday(Birthdate(), RetirementAge() )
  })  
  
  retirementfund <- reactive({
    Road2Retirement()[, "Total"] %>% tail(1) %>% as.integer
  })
  
  output$Totals <- renderText({
    paste("Total retirement fund as of", retirementdate(), "is", retirementfund(), currency(), sep = " ")
  })
          # "Salary", Salary(), "\n",
          # "Birthdate", Birthdate(),"\n",
          # "SalaryGrowthRate", SalaryGrowthRate(),"\n",
          # "CurrentP2", CurrentP2(),"\n",
          # "P2purchase", P2purchase(),"\n",
          # "TypePurchase", TypePurchase(),"\n",
          # "P3purchase", P3purchase(), "\n",
          # "CurrentP3", CurrentP3(), "\n",
          # "returnP3", returnP3(),"\n",
          # "postalcode", postalcode(),"\n",
          # "NKids", NKids(), "\n",
          # "churchtax", churchtax(),"\n",
          # "rate_group", rate_group(),"\n",
          # "TaxRelief", TaxRelief(),"\n",
          # "retirementdate", retirementdate(),"\n",
          # "RetirementAge", RetirementAge(),"\n",
          # "taxRateValue", taxRateValue(),"\n",
          # "Inputcase", Inputcase(), "\n",
          # #"Road2Retirement", Road2Retirement(),
          
  
  # Disclaimer ----
  output$disclaimer <- renderText({
    paste("Disclaimer:",
          "The results of this calculations do not have any legal value.",
          "To check the details of the calculations, parameters and assumptions, please, download the report.",
          sep="\n")
  })
  
  # Output Report ----

  
  #params list to be passed to the output
  params <- list(Salary = isolate(Salary()),
                 birthday = isolate(Birthdate()),
                 Road2Retirement = isolate(Road2Retirement()),
                 SalaryGrowthRate = isolate(SalaryGrowthRate()),
                 CurrentP2 = isolate(CurrentP2()),
                 P2purchase = isolate(P2purchase()),
                 TypePurchase = isolate(TypePurchase()),
                 rate = isolate(BVGMindestzinssatz),
                 P3purchase = isolate(P3purchase()), 
                 CurrentP3 = isolate(CurrentP3()), 
                 returnP3 = isolate(returnP3()),
                 postalcode = isolate(postalcode()),
                 Kanton = isolate(returnPLZKanton(postalcode())),
                 NKids = isolate(NKids()), #ifelse(isolate(input$NKids) >5, 5, isolate(input$NKids)), 
                 churchtax = isolate(churchtax()),
                 rate_group = isolate(rate_group()),
                 MaxContrTax = isolate(TaxRelief()),
                 retirementdate = isolate(retirementdate()),
                 BarGraphData = isolate(BarGraphData()),
                 TserieGraphData = isolate(TserieGraphData()),
                 RetirementAge = isolate(RetirementAge()),
                 TaxRate =  isolate(taxRateValue()),
                 case = isolate(Inputcase())
  )
  
  #output report
  output$report<- downloadHandler(
    filename <- "report.pdf",
    content <- function(file){
      output <- rmarkdown::render(
        input = "report.Rmd",
        output_file = filename,
        output_format = "pdf_document",
#        output_format = "html_document",
        params = params
      )
 #     outputpdf <- webshot::webshot(output, file = "report.pdf")
#      file.copy(outputpdf,file)
      file.copy(output,file)
    }
  )# end of downloadHandler
  
  # refresh inputs ----
  #Refresh plz-gemeinde correspondance
  # when the value of input$refreshButton becomes out of date 
  # (i.e., when the button is pressed)
  refreshText <- eventReactive(input$refreshButton, {downloadInputs(refresh = TRUE)})
  
  output$refreshText<-renderText({
    paste(as.character(refreshText()))
  })
  
  # Conditional TaxRate input ----
  output$conditionalInputSwiss <- renderUI({
    if(input$provideTaxRateSwiss){
      numericInput("TaxRateSwiss", label = h5("Direct Tax Rate (optional)"), value = 1, step = 0.1, min = 0)
    }
    #shinyjs::hide("genre")
  })
  
  # observeEvent(input$provideTaxRateSwiss, {
  #   removeUI(
  #     selector = "div:has(> #genre)"
  #   )
  # })
  
  # Conditional Retirement age input ----
  output$conditionalRetirementAge <- renderUI({
    if(input$provideRetirementAge){
      numericInput("RetirementAge", label = h5("Desired Retirement Age"), value = 65, step = 1, min = 55, max = 70)
    }
  })
  
  # output$ibox <- renderInfoBox({
  #   infoBox(
  #     "i",
  #     "Here some text",
  #     icon = icon("info")
  #   )
  # })
  
  #   BarGraphData <- reactive({
  #     data.frame(Funds = colnames(FotoFinish()),
  #                percentage = as.vector(t(FotoFinish()))) %>%
  #       arrange(Funds) %>%
  #       mutate(pos = cumsum(percentage) - (0.5 * percentage),
  #              percentage = round(percentage * 100, digits = 1),
  #              pos = round(pos * 100, digits = 1)) 
  #   })
  # 
  #   output$plot2 <- renderPlot({
  #     ggplot() + 
  #       geom_bar(aes(y = percentage, x = "", fill = Funds), 
  #                data = BarGraphData(),
  #                position = position_stack(reverse = TRUE),
  #                stat="identity") +
  #       geom_text(data = BarGraphData(),
  #                 aes(x = "", y = pos, label = paste0(percentage,"%")),
  #                 size = 4) +
  #       coord_flip()
  #      
  #   })
  
}
)

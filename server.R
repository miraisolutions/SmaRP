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
#library(ggplot2)

# source core methodology and global variables
source("core.R")


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # calc P2 fund
  ContributionP2Path <- reactive({ 
    buildContributionP2Path(birthday = input$Birthdate,
                            Salary = ifelse(input$case == "General", 0, input$Salary),
                            SalaryGrowthRate = input$SalaryGrowthRate,
                            CurrentP2 = ifelse(input$case == "General", 0, input$CurrentP2),
                            P2purchase = input$P2purchase,
                            TypePurchase = input$TypePurchase,
                            rate = BVGMindestzinssatz,
                            givenday = today())
  })
  
  # calc P3 fund
  ContributionP3path <- reactive({
    buildContributionP3path(birthday = input$Birthdate, 
                            P3purchase = input$P3purchase, 
                            CurrentP3 = input$CurrentP3, 
                            returnP3 = input$returnP3)
  })
  
  # calc Tax benefits
  ContributionTaxpath <- reactive({
    buildTaxBenefits(birthday = input$Birthdate, 
                     TypePurchase = input$TypePurchase,
                     P2purchase = input$P2purchase, 
                     P3purchase = input$P3purchase, 
                     returnP3 = input$returnP3,
                     #                     Salary = ifelse(input$case == "General", input$G_Salary, input$S_Salary),
                     Salary = input$Salary,
                     SalaryGrowthRate = input$SalaryGrowthRate,
                     Kanton = returnPLZKanton(input$postalcode),
                     Tariff = input$tariff, 
                     NKids = input$NKids,
                     churchtax = input$churchtax,
                     rate_group = input$rate_group,
                     MaxContrTax = MaxContrTax)
  })
  
  # build main df
  Road2Retirement <- reactive({
    ContributionP2Path() %>%
      left_join(ContributionP3path(), by = c("calendar", "t")) %>%
      left_join(ContributionTaxpath(), by = c("calendar", "t")) %>%
      mutate(Total = TotalP2 + TotalP3 + TotalTax)             
  }) 
  
  # Table ----
  output$table <- renderTable({
    Road2Retirement()[, c("calendar", "DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")] %>%
      mutate(calendar = paste(year(calendar), month(calendar, label = TRUE), sep = "-"))
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
      options = list(width = 1200, height = 500, isStacked = TRUE, legend = "bottom")
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
      options = list(width = 1200, height = 300, isStacked = TRUE, vAxes = "[{minValue:0}]", legend = "none")
    )
  })
  
  
  retirementdate <- reactive({
    getRetirementday(input$Birthdate)
  })  
  
  retirementfund <- reactive({
    Road2Retirement()[, "Total"] %>% tail(1) %>% as.integer
  })
  
  
  output$Totals <- renderText({
    paste("Total retirement fund as of", retirementdate(), "is", retirementfund(), "CHF", sep = " ")
  })
  
  output$disclaimer <- renderText({
    paste("Disclaimer:",
          "The results of this calculations do not have any legal value.",
          "To check the details of the calculations, parameters and assumptions, please, download the report.",
          sep="\n")
  })
  
  #params list to be passed to the output
  params <- list(Salary = isolate(input$Salary),
                 birthday = isolate(input$Birthdate),
                 Road2Retirement = isolate(Road2Retirement()),
                 SalaryGrowthRate = isolate(input$SalaryGrowthRate),
                 CurrentP2 = ifelse(isolate(input$case) == "General", 0, isolate(input$CurrentP2)),
                 P2purchase = isolate(input$P2purchase),
                 TypePurchase = isolate(input$TypePurchase),
                 rate = isolate(BVGMindestzinssatz),
                 P3purchase = isolate(input$P3purchase), 
                 CurrentP3 = isolate(input$CurrentP3), 
                 returnP3 = isolate(input$returnP3),
                 postalcode = isolate(input$postalcode),
                 Kanton = isolate(returnPLZKanton(input$postalcode)),
                 Tariff = isolate(input$tariff), 
                 NKids = isolate(input$NKids), 
                 churchtax = isolate(input$churchtax),
                 rate_group = isolate(input$rate_group),
                 MaxContrTax = isolate(MaxContrTax),
                 retirementdate = isolate(input$Birthdate),
                 BarGraphData = isolate(BarGraphData()),
                 TserieGraphData = isolate(TserieGraphData())
  )
  
  #output report
  output$report<- downloadHandler(
    filename <- "report.pdf",
    content <- function(file){
      output <- rmarkdown::render(
        input = "report.Rmd",
        output_file = filename,
        output_format = "pdf_document",
        params = params
      )
      file.copy(output,file)
    }
  )# end of downloadHandler
  
  
  #Refresh plz-gemeinde correspondance
  # when the value of input$refreshButton becomes out of date 
  # (i.e., when the button is pressed)
  refreshText <- eventReactive(input$refreshButton, {downloadInputs(refresh = TRUE)})
  
  output$refreshText<-renderText({
    paste(as.character(refreshText()))
  })
  
  output$conditionalInput <- renderUI({
    if(input$provideTaxRate){
      numericInput("TaxRate", label = h5("Direct Tax Rate (optional)"), value = 1, step = 0.1, min = 0)
    }
  })
  
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

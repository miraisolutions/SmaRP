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
library(plyr)
library(magrittr)
library(googleVis)

# source core methodology and global variables
source("core.R")
source("external_inputs.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  # calc P2 fund
  ContributionP2Path <- reactive({ 
    buildContributionP2Path(birthday = input$birthdate,
                            Salary = input$Salary,
                            SalaryGrowthRate = input$SalaryGrowthRate,
                            CurrentP2 = input$CurrentP2,
                            P2purchase = input$P2purchase,
                            TypePurchase = input$TypePurchase,
                            rate = BVGMindestzinssatz,
                            givenday = today())
  })
  
  # calc P3 fund
  ContributionP3path <- reactive({
    buildContributionP3path(birthday = input$birthdate, 
                            P3purchase = input$P3purchase, 
                            CurrentP3 = input$CurrentP3, 
                            returnP3 = input$returnP3)
  })
  
  # calc Tax benefits
  ContributionTaxpath <- reactive({
    buildTaxBenefits(birthday = input$birthdate, 
                     TypePurchase = input$TypePurchase,, 
                     P2purchase = input$P2purchase, 
                     P3purchase = input$P3purchase, 
                     returnP3 = input$returnP3,
                     Salary = input$Salary, 
                     SalaryGrowthRate = input$SalaryGrowthRate,
                     Kanton = input$kanton,
                     Tariff = input$tariff, 
                     NKids = input$NKids, 
                     MaxContrTax = MaxContrTax)
  })
  
  Road2Retirement <- reactive({
    ContributionP2Path() %>%
      merge(ContributionP3path()) %>%
      merge(ContributionTaxpath()) %>%
      mutate(Total = TotalP2 + TotalP3 + TotalTax)
  }) 
  
  output$table <- renderTable({
    Road2Retirement()[, c("calendar", "DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")] %>%
      mutate(calendar = as.Date(calendar))
    
  })
  
  

  output$summary <- renderPrint({
    summary(Road2Retirement())
  })
  
  
  output$plot1 <- renderGvis({
    gvisAreaChart(
      data = Road2Retirement(),
      xvar = "calendar",
      yvar = c("DirectP2", "ReturnP2", "DirectP3", "ReturnP3", "DirectTax", "ReturnTax", "Total"),
      options=list(width = 1200, height = 500)
    ) 
  })
  
  
}
)

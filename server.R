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
library(ggplot2)

# source core methodology and global variables
source("core.R")


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
                     TypePurchase = input$TypePurchase,
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
      left_join(ContributionP3path(), by = c("calendar", "t")) %>%
      left_join(ContributionTaxpath(), by = c("calendar", "t")) %>%
      mutate(Total = TotalP2 + TotalP3 + TotalTax)             
  }) 
  
  FotoFinish <- reactive({
    Road2Retirement()[,c("DirectP2", "ReturnP2", "DirectP3", "ReturnP3", "DirectTax", "ReturnTax")]  %>% 
      tail(1) %>%
      prop.table()
  })
  
  output$table <- renderTable({
    Road2Retirement()[, c("calendar", "DirectP2", "ReturnP2", "TotalP2", "DirectP3", "ReturnP3", "TotalP3", "DirectTax", "ReturnTax", "TotalTax", "Total")] %>%
      mutate(calendar = paste(year(calendar), month(calendar, label = TRUE), sep = "-"))
  }, digits = 0)
  
  

  output$summary <- renderPrint({
    summary(Road2Retirement())
  })
  
  
  output$plot1 <- renderGvis({
    gvisAreaChart(
      data = Road2Retirement(),
      xvar = "calendar",
      yvar = c("DirectP2", "ReturnP2", "DirectP3", "ReturnP3", "DirectTax", "ReturnTax", "Total"),
      options = list(width = 1200, height = 500)
    ) 
  })
  
  output$plot2 <- renderPlot({
    ggplot(data = data.frame(Funds = colnames(FotoFinish()), 
                             value = as.vector(t(FotoFinish()))), 
           aes(x = "", y = value, fill = Funds),
           options = list(width = 1200, height = 50)) + 
      geom_bar(stat="identity") + coord_flip()
  })
  
  
}
)

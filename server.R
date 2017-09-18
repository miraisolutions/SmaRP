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
  Road2Retirement <- reactive({
    buildRoad2Retirement(input$birthdate,
                         BVGMindestzinssatz,
                         input$CurrentP2,
                         input$Salary,
                         input$SalaryGrowthRate,
                         input$P2purchase,
                         input$TypePurchase)

  })
  
  # output$table <- renderGvis({
  #   gvisTable(Road2Retirement(), 
  #             formats=list(Value="#,###"))
  # })
  
  output$table <- renderTable({
    Road2Retirement()[, c("calendar", "DirectP2", "ReturnP2", "TotalP2")] %>%
      mutate(calendar = as.Date(calendar))
    
  })
  
  

  output$summary <- renderPrint({
    summary(Road2Retirement())
  })
  
  
  # output$plot1 <- renderPlotly({
  #   
  #   # ggplot(data, aes(x=Year, y=Value, fill=Sector)) +
  #   #   geom_area(colour="black", size=.2, alpha=.4) +
  #   #   scale_fill_brewer(palette="Greens", breaks=rev(levels(data$Sector)))
  #   
  #   p <- ggplot(Road2Retirement(), aes(calendar, BVGcontributions)) +
  #     geom_area(colour="black", size=.2, alpha=.4) +
  #     xlab("") +
  #     ylab("")
  #     
  #   # + geom_area() 
  #   # + xlab("")
  #   # + ylab("")
  #   p <- p + geom_point()
  #   ggplotly(p)
  # })
  
  output$plot1 <- renderGvis({
    
    gvisAreaChart(
      data = Road2Retirement(),
      xvar = "calendar",
      yvar = c("ReturnP2", "DirectP2", "TotalP2"),
      options = list(heigth = 800, width = 800)
    )
    
    

    # ggplot(data, aes(x=Year, y=Value, fill=Sector)) +
    #   geom_area(colour="black", size=.2, alpha=.4) +
    #   scale_fill_brewer(palette="Greens", breaks=rev(levels(data$Sector)))

    # p <- ggplot(Road2Retirement(), aes(calendar, BVGcontributions)) +
    #   geom_area(colour="black", size=.2, alpha=.4) +
    #   xlab("") +
    #   ylab("")
    # 
    # # + geom_area()
    # # + xlab("")
    # # + ylab("")
    # p <- p + geom_point()
    # ggplotly(p)
  })
  
  
}
)

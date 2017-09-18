#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# UI
shinyUI(  fluidPage(
  
  titlePanel("Swiss Retirement Calculator"),
  a(href="http://www.mirai-solutions.com", "mirai-solutions.com"),
  hr(),
  sidebarLayout(
    sidebarPanel(
      selectInput("select", label = h5("Generic Info"), 
                  choices = list("Zurich" = "ZH", "St.Gallen" = "SG", "Bern" = "BE"), 
                  selected = "ZH"),
      selectInput("select", label = NULL, 
                  choices = list("Male" = "M", "Female" = "F"), 
                  selected = "M"),
      dateInput("birthdate", label = NULL, value = "1980-12-31", format = "yyyy-mm-dd"),
      numericInput(
        "Salary", 
        label = h5("Current Annual Salary"), 
        value = 100000, 
        step = 1000
      ),
      numericInput("CurrentP2", label = h5("Current Pilar 2 amount"), value = 100000, step = 1000),
      numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.02, step = 0.001),
      numericInput("P2purchase", label = h5("Pilar II purchase"), value = 0, step = 500),
      radioButtons("TypePurchase", label = NULL,
                   c("Single Purchase" = "SingleP2",
                     "Annual Purchase" = "AnnualP2"))
      
       
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", htmlOutput("plot1")),
                  tabPanel("Summary", verbatimTextOutput("summary")),
                  tabPanel("Table", htmlOutput("table"))
      )
       
    )
  )
))

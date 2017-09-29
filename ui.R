#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source("external_inputs.R")

# UI
shinyUI(  fluidPage(
  
  titlePanel("Swiss Retirement Calculator"),
  a(href="http://www.mirai-solutions.com", "mirai-solutions.com"),
  hr(),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("kanton", "Basic Info",
                  choices = Kanton.list ,
                  selected = "ZH"),
      radioButtons("genre", label = NULL, inline = TRUE,
                  choices = list("Male" = "M", "Female" = "F"), 
                  selected = "M"),
      selectInput("tariff", label = NULL, 
                  choices = tariffs.list, 
                  selected = "TA"),
      radioButtons("NKids", label = NULL, inline = TRUE,
                   choices = Kids.list,
                   selected = "0kid"),
      
      dateInput("birthdate", label = h5("Birthday"), value = "1980-12-31", format = "yyyy-mm-dd"),
      #      HTML('<hr style="color: black;">'),
      hr(),
      tags$div(class="header", checked=NA, tags$p("Pilar 2")),
      numericInput(
        "Salary", 
        label = h5("Current Annual Salary"), 
        value = 100000, 
        step = 1000
      ),
      numericInput("CurrentP2", label = h5("Current Pilar 2 amount"), value = 100000, step = 1000),
      numericInput("SalaryGrowthRate", label = h5("Expected salary growth rate"), value = 0.02, step = 0.001),
      numericInput("P2purchase", label = h5("Pilar 2 purchase"), value = 0, step = 500),
      radioButtons("TypePurchase", label = NULL, inline = TRUE,
                   c("Single Purchase" = "SingleP2",
                     "Annual Purchase" = "AnnualP2")),
      hr(),
      tags$div(class="header", checked=NA, tags$p("Pilar 3")),
      numericInput("CurrentP3", label = h5("Current Pilar 3 amount"), value = 50000, step = 1000),
      numericInput("P3purchase", label = h5("Annual Pilar 3 purchase"), value = 0, step = 500),
      numericInput("returnP3", label = h5("Expected Return Pilar 3"), value = 0, step = 500)
      
      
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", htmlOutput("plot1")),
                  tabPanel("Plot", plotOutput("plot2")),
                  tabPanel("Summary", verbatimTextOutput("summary")),
                  tabPanel("Table", htmlOutput("table"))
      )
      
    )
  )
))

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyhydat)
library(tidyverse)
library(ggplot2)

#define default for everything
#load default stations from TidyHydat - note that it returns a tibble so [[ ]] required
all_stations<-allstations
my_list<-all_stations[[1]]
val=all_stations[[1,1]]
my_data<-hy_daily_flows(station_number=val)
start_date=my_data[[1,2]]
last=nrow(my_data)
stop_date=my_data[[last,2]]

#set teh min and max dates and they remain fixed
min_date<-start_date
max_date<-stop_date

# Define UI for application that draws a histogram
ui <- fluidPage(
   
  # Application title
  titlePanel("Hydat Plotting"),
   
   # Sidebar with a slider input for number of bins 
  wellPanel(dateRangeInput("dateRange",
                           label = paste("Start and Stop dates"),
                           start = start_date, end = stop_date,
                           min = min_date, max = max_date,
                           separator = " - ", 
                           language = 'en'),
      # get text input
        selectInput("station_val", label = h3("Station Number"), choices=my_list,selected=1),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  
  #get stop and start dates from user input
  data <- reactive({
    val<-input$station_val
    my_data<-hy_daily_flows(station_number=val)
    start_date=my_data[[1,2]]
    last=nrow(my_data)
    stop_date=my_data[[last,2]]
    min_date<-start_date
    max_date<-stop_date
    updateDateRangeInput(session,"dateRange",
                         label = paste("Start and Stop dates"),
                         start = start_date, end = stop_date,
                         min = min_date, max = max_date)
  })
   
   output$distPlot <- renderPlot({
     data()
     val<-isolate(input$station_val)
     
     #need to convert dates to string for tidyHydat
     my_stop<-as.character(input$dateRange[2])
     my_start<-as.character(input$dateRange[1])
     
     #extraxct data
     my_data<-hy_daily_flows(station_number=val,start_date=my_start,end_date = my_stop)
      
     # draw the time series plot of the hydrograph
     ggplot(my_data, aes(Date, Value)) + geom_line() +
       scale_x_date(date_labels ="%b %Y") + xlab("") + ylab("Daily flow (CMS)")
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)


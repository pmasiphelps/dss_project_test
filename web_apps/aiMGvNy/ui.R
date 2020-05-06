library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$head(tags$style("#shiny-notification-panel {top: 40% !important;left: 45% !important;font-size: 20px}"),
           
           tags$style(".modal button {display:none}"),
           tags$style(".scenario-loader {margin-top:20%}"),
           tags$style("#shiny-modal {margin-top:10%}",".shiny-download-link {margin-bottom:5%}")),

  # Application title
  titlePanel("File Upload"),
   

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
      
      # Input: Select a file ----
      
    sidebarPanel(
    fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv")),
    
   actionButton("button", "Run Flow")


    ),
      

    # Show a plot of the generated distribution
    mainPanel(
        uiOutput("downloadData"),
        dataTableOutput("Table")

    )
  ))
       
     )
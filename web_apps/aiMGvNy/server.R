# This file is the actual code for the R backend of your Shiny webapp Web-app-kit_r-upload-file
library(shiny)
library(httr)
library(dplyr)
library(dataiku)

INSTANCE_URL <- ### THE URL OF YOUR DSS INSTANCE HERE
PROJECT_KEY <- ### YOUR PROJECT KEY HERE
API_KEY <- ### YOUR API KEY HERE
SCENARIO_ID <- ### THE ID OF YOUR SCENARIO HERE
OUTPUT_DATASET <- ### THE NAME OF YOUR OUTPUT DATASET HERE
INPUT_DATASET <- ### THE NAME OF YOUR INPUT DATASET HERE

shinyServer(function(input, output) {
    
   ### HERE WE DEFINE A SET OF COMMANDS TO BE RAN WHEN THE USER CLICKS ON THE RUN FLOW BUTTON 
    observeEvent(input$button, {    
   
   ### Conditional statement to check that the user has uploaded a file before clicking on Run flow
    req(input$file1)

    ### showing loading modal to users while scenario is loading, that way we make sure that users don't trigger the scenario several times
    showModal(modalDialog(
        HTML('<h3 style="text-align:center">Loading... </h3>  
        <img src="http://gifimage.net/wp-content/uploads/2018/04/progress-bar-gif-8.gif" style="margin-left:10%"/>')
        
      ))
    
    ### Gettting the uploaded dataset from the input and writing it on the flow
    df_init <- read.csv(input$file1$datapath)
    dkuWriteDataset(df_init,INPUT_DATASET, schema = TRUE)
    
    ### Launching scenario
    r<-POST(paste(INSTANCE_URL,"/public/api/projects/",PROJECT_KEY,"/scenarios/",SCENARIO_ID,"/run", sep=""), authenticate(API_KEY,""))

        
        
    ### Loop over scenario to check whether the scenario is done running or not
    status <- 'TRUE'
    while (status=='TRUE')
    {
        status<-content(GET(paste(INSTANCE_URL,"/public/api/projects/",PROJECT_KEY,"/scenarios/",SCENARIO_ID,"/light",sep=""), authenticate(API_KEY,"")))$running
        Sys.sleep(0.5)
    
    }
        
    ### Check that the scenario was successful
    run<-content(GET(paste(INSTANCE_URL,"/public/api/projects/",PROJECT_KEY,"/scenarios/",SCENARIO_ID,"/get-last-runs/?limit=1",sep=""),add_headers('Content-Type' = "json") ,authenticate(API_KEY,"")))
    if (run[[1]]$result$outcome == 'SUCCESS') {
        # get final dataset and output it as a table in the Webapp 
        output$Table <- renderDataTable ({
            
            df <- dkuReadDataset(OUTPUT_DATASET)
        })
    
    ### Addind a button to download the output dataset as a csv file   
    output$downloadData <- renderUI({
    downloadButton("downloadData01","Download Results")
  })
        
        }
   output$downloadData01 <- downloadHandler(
    filename = function() {
      "output_data.csv"
    },
    content = function(file) {
      write.csv(df, file, row.names = FALSE)
    }
  )
        
   ### Hiding modal
   removeModal()

   
    })
  })

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(lubridate)

get_tweets <- function(path) {
  tweet_files <- list.files(path = path,
                            pattern = "tweets.*\\.RDS",
                            full.names = TRUE)
  
  tweet_files %>% 
      purrr::map(readRDS) %>% 
      dplyr::bind_rows()
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            textInput("data", h3("Data folder"), "~/GitHub/tweetminer/data/"),
            actionButton("submit", "Submit", icon("refresh")),
                 conditionalPanel("input.submit > 0",
                                sliderInput("date", label = h3("Date range"), min = 0, 
                                             max = 0, value = c(0, 0)),
                                textInput("filter", h4("Search string"), ""),
                                checkboxInput("ignore_case", h5("Ignore case")),
                                actionButton("update", "Filter"),
                                h5("Summary:"),
                                tableOutput("summary")
                                ),
        ),

        # Show a plot of the generated distribution
        mainPanel(
            fluidRow(
                column(4,
                wellPanel(
                textOutput("show_tweet"),
                            style = "min-height:205px"),
                actionButton("prev_tweet", "Back"), actionButton("next_tweet", "Next")
                )
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    tweets <- eventReactive(input$submit, {
        
        path <- do.call(file.path, as.list(stringr::str_split(input$data, "/")[[1]]))
        
        tweets <- get_tweets(path)
        
        return(tweets)
        })
    
    tweets_filtered <- eventReactive(input$update, {

            date_filter <- tweets() %>%
                filter(created_at >= input$date[1], created_at <= input$date[2])
            
            if(input$filter != "") {
                final_filter <- date_filter %>% 
                filter(stringr::str_detect(.$text, stringr::regex(input$filter, ignore_case = input$ignore_case)))
            } else final_filter <- date_filter
    })
    
    observe({
        updateSliderInput(session, "date",
                          min = as_date(min(tweets()$created_at)),
                          max = as_date(max(tweets()$created_at)))
    })

    output$summary <- renderPrint({
        # input$update
        skimr::skim(tweets_filtered()) %>%
            summary() %>% 
            knitr::kable("html")
    })
    
    output$show_tweet <- renderPrint({
        counter <- 1 + (input$next_tweet - input$prev_tweet)
        index <- if_else(counter < 1, 1, as.numeric(counter))
        cat(tweets_filtered()$text[index])
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

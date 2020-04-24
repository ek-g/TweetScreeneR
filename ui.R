
ui <- fluidPage(
    
    useShinyjs(),  
  
    titlePanel("TweetScreeneR"),
    
    sidebarLayout(
        sidebarPanel(
            textInput("data", h3("Data folder"), "./testdata/"),
            actionButton("submit", "Submit", icon("refresh")),
                 conditionalPanel("input.submit > 0",
                                sliderInput("date", label = h3("Date range"), min = 0, 
                                             max = 0, value = c(0, 0)),
                                textInput("filter", h4("Search string"), ""),
                                checkboxInput("ignore_case", "Ignore case"),
                                checkboxInput("replace_mentions", "Anonymize @mentions", TRUE),
                                
                                splitLayout(
                                actionButton("update", "Filter"),
                                disabled(actionButton("start", "Start", class = "btn-primary")),
                                cellWidths = c("50%", "50%")),
                                
                                p(textOutput("summary"))
                                ),
        width = 2),

        mainPanel(
            fluidRow(
                column(4,
                wellPanel(
                htmlOutput("show_tweet"),
                            style = "min-height:240px"),
                disabled(
                actionButton("prev_tweet", "Back"),
                br(),br(),
                p(
                actionButton("include_tweet", "Include", class = "btn-success"),
                actionButton("exclude_tweet", "Exclude", class = "btn-danger"))
                )
                )
            )
        )
    )
)


ui <- fluidPage(
    
    useShinyjs(),  
  
    titlePanel("TweetScreeneR"),
    
    sidebarLayout(
        sidebarPanel(
          tabsetPanel(
          tabPanel(title = "Settings",
            textInput("data", h4("Import folder"), "./testdata/"),
            actionButton("submit", "Import tweets", icon("refresh")), textOutput("tweet_count", inline = TRUE),
                 conditionalPanel("input.submit > 0",
                                sliderInput("date", label = h4("Date range"), min = 0, 
                                             max = 0, value = c(0, 0)),
                                textInput("filter", h4("Search string"), ""),
                                checkboxInput("ignore_case", "Ignore case"),
                                checkboxInput("replace_mentions", "Anonymize @mentions", TRUE),
                                checkboxInput("remove_screened", "Remove already screened tweets", TRUE),
                                
                                actionButton("update", "Filter", icon("filter"), class = "btn-block"),
                                br(),
                                disabled(actionButton("start", "Start", icon("play"), class = "btn-primary btn-block")),
                                br(),
                                p(textOutput("summary"))
                                ), # END conditionalPanel
          ), # END tabPanel
          tabPanel(title = "Advanced",
                   textInput("output_folder", h4("Output folder:"), "data"),
                   # checkboxInput("custom_buttons", "Custom labels"),
                   # textInput("buttons", h5("Labels (comma separated):")),
                   # actionButton("add_buttons", "Add")
                   )
                      ),
          width = 3), # END sidebarPanel

        mainPanel(
            fluidRow(
                column(4,
                wellPanel(
                htmlOutput("show_tweet"),
                            style = "min-height:240px"),
                disabled(
                actionButton("prev_tweet", "Previous"),
                actionButton("next_tweet", "Next")),
                uiOutput("buttons"),
                br(),br()
                )
                ), # End fluidRow
                fluidRow(
                  column(2,
                         disabled(
                  actionButton("include_tweet", "Include", class = "btn-success btn-block"))
                  ),
                  column(2,
                         disabled(
                  actionButton("exclude_tweet", "Exclude", class = "btn-danger btn-block"))
                  )
                )
        ) # END mainPanel
    ) # END sidebarLayout
)

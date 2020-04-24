
server <- function(input, output, session) {
  
  tweets <- eventReactive(input$submit, {
    
    path <- do.call(file.path, as.list(stringr::str_split(input$data, "/")[[1]]))
    
    tweets <- get_tweets(path)
    
    return(tweets)
  })
  
  
  
  tweets_filtered <- eventReactive(input$update, {
    
    enable("start")
    index <<- 1
    date_filter <- tweets() %>%
      filter(between(as.Date(created_at), as.Date(input$date[1]), as.Date(input$date[2])))
    
    if(input$filter != "") {
      final_filter <- date_filter %>% 
        filter(stringr::str_detect(.$text, stringr::regex(input$filter, ignore_case = input$ignore_case)))
    } else final_filter <- date_filter
    
    if(input$replace_mentions == TRUE) {
      final_filter %>% 
        mutate(text = str_replace_all(text, "@[A-Za-z0-9_\\-]+", "@mention"))
    } else final_filter
  })
  
  observe({
    updateSliderInput(session, "date",
                      min = as_date(min(tweets()$created_at)),
                      max = as_date(max(tweets()$created_at)),
                      value = c(as_date(min(tweets()$created_at)), as_date(max(tweets()$created_at))))
  })
  
  observeEvent(input$start, {
    data_buttons %>% 
      map(toggleState)
    UI_buttons %>% 
      map(toggleState)
    
    toggle_label <- if_else(input$start %% 2 == 0, "Start", "Stop")
    
    updateActionButton(session, "start", label = toggle_label)
    
    if(toggle_label == "Stop") {
      output_file <<- reset_output(input$filter)
      write_csv(screened_tweets, output_file, col_names = TRUE)
    }
    
    if(toggle_label == "Start") disable("start")
  })
  
  observeEvent(input$include_tweet, {
    if(index != nrow(tweets_filtered()) + 1){ 
      screened_tweets <<- bind_rows(screened_tweets, tweet_decision(tweets_filtered(), "Include"))
      write_csv(screened_tweets, output_file, append = TRUE)
      index <<- index + 1}
  })
  
  observeEvent(input$exclude_tweet, {
    if(index != nrow(tweets_filtered()) + 1){ 
      screened_tweets <<- bind_rows(screened_tweets, tweet_decision(tweets_filtered(), "Exclude"))
      write_csv(screened_tweets, output_file, append = TRUE)
      index <<- index + 1}
  })
  
  observeEvent(input$prev_tweet, if(index != 1){ index <<- index - 1 })
  
  output$summary <- renderPrint({
    cat("Tweets found:", nrow(tweets_filtered()))
  })
  
  
  output$show_tweet <- renderPrint({
    input$include_tweet
    input$exclude_tweet
    input$prev_tweet
    input$start
    input$update
    HTML(
      paste0("Tweet ", index, "/", nrow(tweets_filtered()),
             "<br/><br/>",
             tweets_filtered()$text[index])
    )
  })
}

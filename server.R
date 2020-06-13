
server <- function(input, output, session) {
  
# Load data
  
  tweets <- eventReactive(input$submit, {
    
    path <- do.call(file.path, as.list(stringr::str_split(input$data, "/")[[1]]))
    
    tweets <- get_tweets(path)
    
    return(tweets)
  })
  
  output$tweet_count <- renderPrint({
    cat(nrow(tweets()), "tweets imported")
    })
  
  
# Filter data
  
  tweets_filtered <- eventReactive(input$update, {
    
    c("start", "prev_tweet", "next_tweet") %>% 
    map(enable)
    
    index <<- 1
    date_filter <- tweets() %>%
      filter(between(as.Date(created_at), as.Date(input$date[1]), as.Date(input$date[2])))
    
    # Implement search
    
    if(input$filter != "") {
      final_filter <- date_filter %>% 
        filter(stringr::str_detect(.$text, stringr::regex(input$filter, ignore_case = input$ignore_case)))
    } else final_filter <- date_filter
    
    # Anonymize @mentions
    
    if(input$replace_mentions == TRUE) {
      final_filter <- final_filter %>% 
        mutate(text = str_replace_all(text, "@[A-Za-z0-9_\\-]+", "@mention"))
    }
    
    # remove already screened
    
    if(input$remove_screened == TRUE) {
      already_screened <- list.files(input$output_folder,
                                     pattern = "screened_tweets.*\\.csv",
                                     full.names = TRUE)
      already_screened <- already_screened %>% 
        map(read_csv, col_types = "ccc") %>% 
        bind_rows()
      final_filter <- final_filter[!final_filter$status_id %in% already_screened$status_id,]
    }
    
    return(final_filter)
  })
  
# Make the input slider range and defaults reactive to data
  
  observe({
    updateSliderInput(session, "date",
                      min = as_date(min(tweets()$created_at)),
                      max = as_date(max(tweets()$created_at)),
                      value = c(as_date(min(tweets()$created_at)), as_date(max(tweets()$created_at))))
  })
  
# Start button
  
  observeEvent(input$start, {
    # Disable data buttons (side panel)
    data_buttons %>% 
      map(toggleState)
    # Enable UI buttons
    UI_buttons %>% 
      map(toggleState)
    
    # Make the button label and update it
    toggle_label <- if_else(input$start %% 2 == 0, "Start", "Stop")
    toggle_icon <- icon(if_else(input$start %% 2 == 0, "play", "stop"))
    updateActionButton(session, "start", label = toggle_label, icon = toggle_icon)
    
    # When started, create the session file by resetting the output
    if(toggle_label == "Stop") {
      if(!dir.exists(input$output_folder)) dir.create(input$output_folder)
      output_file <<- reset_output(input$output_folder, input$filter)
      write_csv(screened_tweets, output_file, col_names = TRUE)
    }
    # Disable start if filter not applied a second time
    if(toggle_label == "Start") disable("start")
  })
  
  # Save decisions to a file
  
  observeEvent(input$include_tweet, {
    decision_action(tweets_filtered(), "Include")
  })
  
  observeEvent(input$exclude_tweet, {
    decision_action(tweets_filtered(), "Exclude")
  })

  
  # Basic navigation:
  
  observeEvent(input$prev_tweet, if(index != 1){ index <<- index - 1 })
  observeEvent(input$next_tweet, if(index < nrow(tweets_filtered())){ index <<- index + 1 })
  
  # Number of found tweets
  
  output$summary <- renderPrint({
    cat("Tweets found:", nrow(tweets_filtered()))
  })
  
  # observeEvent(input$custom_buttons, map(c("buttons", "add_buttons"), toggleState))
  # 
  # observeEvent(input$add_buttons, {
  #   
  #   buttons <- str_squish(str_split(input$buttons, ",")[[1]])
  #   
  #   isolate({output$buttons <- renderUI({
  #     btn_ids <<- paste0("btn_", buttons)
  #     btn_labels <<- buttons
  #     map2(btn_ids, btn_labels, actionButton)})
  #   
  #   for(ii in 1:length(labels)){
  #     local({
  #       i <- ii
  #       observeEvent(eventExpr = input[[paste0(btn_ids[i])]],
  #                    handlerExpr = {alert(sprintf("You clicked btn named %s",btn_labels[i]))})
  #     })
  #   }
  #   })
  # })
  
  # Render the filtered tweets
  
  output$show_tweet <- renderPrint({
    input$include_tweet
    input$exclude_tweet
    input$prev_tweet
    input$next_tweet
    input$start
    input$update
    HTML(
      if(nrow(tweets_filtered()) == 0) {
           paste0("No tweets found!")
      } else {
      paste0("Tweet ", index, "/", nrow(tweets_filtered()),
             "<br/><br/>",
              tweets_filtered()$text[index])
        }
      )
  })
}

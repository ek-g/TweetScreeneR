library(shiny)
library(shinyjs)
library(shinyalert)
library(tidyverse)
library(lubridate)
library(digest)

# FUN: Get all tweets from .RDS files

get_tweets <- function(path) {
  tweet_files <- list.files(path = path,
                            pattern = "tweets.*\\.RDS",
                            full.names = TRUE)
  
  tweet_files %>% 
    purrr::map(readRDS) %>% 
    dplyr::bind_rows()
}

# FUN: Save the decision data

decision_action <- function(data, decision) {
    cur_decision <- tweet_decision(data, decision)
    
    if(cur_decision$status_id %in% screened_tweets$status_id) {
      screened_tweets[screened_tweets$status_id == cur_decision$status_id,] <<- cur_decision
      write_csv(screened_tweets, output_file)
    } else {
      screened_tweets <<- bind_rows(screened_tweets, cur_decision)
      write_csv(cur_decision, output_file, append = TRUE)
    }
    
  if(index < nrow(data)) { 
    index <<- index + 1 
    } else {
      shinyalert("Nice!", "You've succesfully screened the last tweet. All your decisions have been saved — you may now press 'Stop'.", type = "success")
    }
}

# FUN: Create the data to be exported

tweet_decision <- function(data, decision) {
  data %>% 
    slice(index) %>% 
    mutate(decision = decision) %>% 
    select(text, decision, status_id)
}

# FUN: Create unique session file based on hashed timestamp

reset_output <- function(output_folder, string) {
  file.path(output_folder, paste0("screened_tweets_", str_extract(string, "[A-Za-z]+"), "_", Sys.Date(), "-", digest(Sys.time()), ".csv"))
}

# Create empty df for data to be exported

screened_tweets <- tibble(text = character(),
                          decision = character(),
                          status_id = character())

# Buttons on sidepanel

data_buttons <- c("submit", "update", "filter", "date", "data", "ignore_case", "replace_mentions", "remove_screened")

# UI buttons

UI_buttons <- c("next_tweet", "include_tweet", "exclude_tweet")

# Tweet index

index <- 1

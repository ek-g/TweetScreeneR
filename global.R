library(shiny)
library(shinyjs)
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

# FUN: Create the data to be exported

tweet_decision <- function(data, decision) {
  data %>% 
    slice(index) %>% 
    mutate(decision = decision) %>% 
    select(text, decision, status_id)
}

# FUN: Create unique session file based on hashed timestamp

reset_output <- function(string) {
  file.path(output_folder, paste0("screened_tweets_", str_extract(string, "[A-Za-z]+"), "_", Sys.Date(), "-", digest(Sys.time()), ".csv"))
}

# Create empty df for data to be exported

screened_tweets <- tibble(text = character(),
                          decision = character(),
                          status_id = character())

# Buttons on sidepanel

data_buttons <- c("submit", "update", "filter", "date", "data", "ignore_case")

# UI buttons

UI_buttons <- c("prev_tweet", "include_tweet", "exclude_tweet")

#TODO: Add an option to change the folder

output_folder <- "data"
if(!dir.exists(output_folder)) dir.create(output_folder)

# Create index

index <- 1

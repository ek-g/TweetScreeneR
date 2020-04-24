library(shiny)
library(shinyjs)
library(tidyverse)
library(lubridate)
library(digest)

get_tweets <- function(path) {
  tweet_files <- list.files(path = path,
                            pattern = "tweets.*\\.RDS",
                            full.names = TRUE)
  
  tweet_files %>% 
    purrr::map(readRDS) %>% 
    dplyr::bind_rows()
}

tweet_decision <- function(data, decision) {
  data %>% 
    slice(index) %>% 
    mutate(decision = decision) %>% 
    select(text, decision, status_id)
}

reset_output <- function(string) {
  file.path(output_folder, paste0("screened_tweets_", str_extract(string, "[A-Za-z]+"), "_", Sys.Date(), "-", digest(Sys.time()), ".csv"))
}

screened_tweets <- tibble(text = character(),
                          decision = character(),
                          status_id = character())

data_buttons <- c("submit", "update", "filter", "date", "data", "ignore_case")

UI_buttons <- c("prev_tweet", "include_tweet", "exclude_tweet")

output_folder <- "data"

index <- 1

if(!dir.exists(output_folder)) dir.create(output_folder)

# The script defines functions which retrieve famous qoutes from startrek

# Read the complete dataset and the reference lookup dataset

complete_dataset <- jsonlite::fromJSON("raw_data/all_series_lines.json",
                                       flatten = T)

# This is the dataset from which the quote is going to be randomized
startrek_ref <- read_csv("raw_data/characters_words.csv") %>%
  filter(total_words > 0) %>% 
  mutate(episode = episode - 1) %>% 
  group_by(character) %>% 
  mutate(total_character_words = sum(total_words)) %>% 
  filter(total_character_words >= 15000) %>% 
  select(-total_character_words)

# the copyright str for fixing it
copyright_str <- " <Backto the episode listingStar Trek ® and relatedmarks are trademarks of Studios Inc. Copyright © 1966, Present. The Star Trek web pages on this site are foreducational and entertainment purposes only. All other copyrightsproperty of their respective holders."


# here is the original function:
get_random_quote <- function(character_fl = unique(startrek_ref$character), 
                             series_fl = unique(startrek_ref$series)){
  
  
  
  quote_from <- startrek_ref %>% 
    ungroup() %>% 
    filter(character %in% character_fl) %>% 
    filter(series %in% series_fl)
  
  if (NROW(quote_from) == 0) {
    # no possible quote for this combination? return NA
    return(NA)
  } else {
    finalize_quote <- quote_from %>% 
      sample_n(1)
  }
  
  episode_fl <- paste0("episode ", finalize_quote$episode)
  line_to_retrieve <- round(runif(1, min = 1, max = finalize_quote$script_lines))
  

  # generate the quote
  quote_to_return <- tryCatch(expr = 
                                {str_replace(complete_dataset[[finalize_quote$series]][[episode_fl]][[finalize_quote$character]][[line_to_retrieve]], 
                                            copyright_str, "")},
                              error = NA)
  
  # return the following quote
  if (!is.na(quote_to_return)){
    list(character = finalize_quote$character,
         series = finalize_quote$series,
         episode = finalize_quote$episode + 1,
         line = line_to_retrieve,
         quote = quote_to_return)
  } else {
    # no quote found? return NA
    NA
  }
}

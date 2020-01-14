# Rearrange star trek quotes into a nice dataset

library(tidyverse)

trek_tibble_raw <- jsonlite::fromJSON("raw_data/all_series_lines.json",
                                      flatten = T)


# Retrieve a table of lines and words per each character ------------------

copyright_str <- " <Backto the episode listingStar Trek ® and relatedmarks are trademarks of Studios Inc. Copyright © 1966, Present. The Star Trek web pages on this site are foreducational and entertainment purposes only. All other copyrightsproperty of their respective holders."

retrieve_characters_in_chapters <- function(chapter_script_lines){
  map_df(chapter_script_lines, 
      ~{
        tibble(total_words = str_replace(., 
                                         fixed(copyright_str),
                                         "") %>% 
                 str_count() %>% 
                 sum(), 
               script_lines = NROW(.))
      }) %>% 
    mutate(character = names(chapter_script_lines))
}

## NOT RUN
# retrieve_characters_in_chapters(trek_tibble_raw$TNG$`episode 0`)


# Iterate the retrieval of lines and words for an entire series -----------

retrieve_characters_in_series <- function(series_script_lines){
  tibble(
    episode_details = map(series_script_lines,
                          ~{
                            retrieve_characters_in_chapters(.)
                            }),
    episode = names(series_script_lines)
  )
}

## NOT RUN:
# pb <- progress_estimated(length(trek_tibble_raw$TNG))
# tng_raw <- retrieve_characters_in_series(trek_tibble_raw$TNG)
# tng_episodes <- tng_raw %>% 
#   unnest(episode_details) %>% 
#   mutate(episode = (str_replace_all(episode, "[a-z\\s]", "") %>% as.numeric()) + 1) %>% 
#   group_by(character) %>% 
#   add_tally(total_words) %>%
#   filter(n > 10000)


# Iterate over all series -------------------------------------------------

characters_in_all_raw <- 
  tibble(all_scripts_summarized = map(trek_tibble_raw,
                                      ~{
                                        retrieve_characters_in_series(.) %>% 
                                          unnest(episode_details)
                                      }),
         series = names(trek_tibble_raw))

characters_words <- characters_in_all_raw %>% 
  unnest(all_scripts_summarized) %>% 
  mutate(episode = (str_replace_all(episode, "[a-z\\s]", "") %>% as.numeric()) + 1)

# Example: distribution of number of words per episode, for five starfleet captains
characters_words %>% 
  group_by(character, series) %>% 
  add_tally(total_words) %>%
  filter(n > 50000) %>% 
  filter(character %in% c("ARCHER", "JANEWAY", "PICARD", "KIRK", "SISKO")) %>% 
  ggplot(aes(sample=total_words)) + geom_qq_line() + geom_qq() + facet_wrap(~character)
  
# Example: linear model for the number of words as a function of script lines per episode, 
#          for the five starfleet captains

starfleet_captain_lm <- characters_words %>% 
  filter(series != "TOS") %>% 
  group_by(character, series) %>% 
  add_tally(total_words) %>%
  filter(n > 50000) %>% 
  filter(character %in% c("ARCHER", "JANEWAY", "PICARD", "KIRK", "SISKO")) %>% 
  lm(data = ., formula = total_words ~ script_lines*character)

summary(starfleet_captain_lm)

characters_words %>% 
  filter(series != "TOS") %>% 
  group_by(character, series) %>% 
  add_tally(total_words) %>%
  filter(n > 50000) %>% 
  filter(character %in% c("ARCHER", "JANEWAY", "PICARD", "KIRK", "SISKO")) %>% 
  ggplot(aes(x = script_lines, y = total_words)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  facet_wrap(~character)

## RUN ONCE:
# write_csv(characters_words, "raw_data/characters_words.csv")

characters_words %>% 
  filter(series != "TOS") %>% 
  group_by(character, series) %>% 
  add_tally(total_words) %>%
  filter(n > 50000) %>% 
  filter(character %in% c("ARCHER", "JANEWAY", "PICARD", "KIRK", "SISKO")) %>% 
  ggplot(aes(x = character, y = total_words)) + 
  geom_boxplot()

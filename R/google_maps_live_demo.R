# Google maps API live demo

library(tidyverse)
library(httr)

# The key is not a part of this repo so reading it won't work. You have to register your own key.

my_key <- read_csv("secret_keys/google_maps_key.csv")$key[1]

# Defines the parameters we will use ----

my_origins <- "30th Kalisher, Tel-Aviv"
my_destinations <- "Azriely Center, Tel-Aviv|Netanya|Haifa|Jerusalem|Beer-Sheva|Eilat|Metula|Kiryat Shmona|Antartica"

# Did you notice the last location?

# The base link of the api ----

url <- "https://maps.googleapis.com/maps/api/distancematrix/json"


# Build the query ---------------------------------------------------------

my_query <- list(key = my_key,
                 origins = my_origins,
                 destinations = my_destinations,
                 units = "metric",
                 mode = "bicycling")


# Send the query, get results ---------------------------------------------

# get the raw data
riding_times <- httr::GET(url, query = my_query)
status_code(riding_times)
httr::http_status(riding_times)

riding_tibble <- as_tibble(content(riding_times), validate = T) %>% 
  unnest(cols = c(destination_addresses, origin_addresses)) %>% 
  unnest(rows) %>% 
  mutate(ride_time_dist = map(rows[[1]], 
                              ~{
                                if ("distance" %in% names(.)){
                                  tibble(distance = as.numeric(.$distance$value),
                                         riding_time = as.numeric(.$duration$value))
                                } else {
                                  tibble(distance = NA,
                                         riding_time = NA)
                                }
                              })) %>% 
  unnest(ride_time_dist) %>% 
  select(-rows, -status) %>% 
  slice(7, 8, 3, 2, 1, 4, 5, 6, 9) %>% 
  filter(!is.na(riding_time)) %>% 
  mutate(destination_addresses = fct_inorder(str_wrap(destination_addresses, width = 20))) 


# Lets wrap this up with a plot -------------------------------------------

ggplot(riding_tibble, aes(x = destination_addresses, y = riding_time/3600)) + 
  geom_col(fill = "lightblue", color = "black") + 
  xlab("Ride to...") + 
  ylab("Time [hr]") +
  theme_bw() + 
  coord_flip()

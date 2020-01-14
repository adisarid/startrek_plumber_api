# The startrek quote generator API via plumber

# Created by Adi Sarid. 
# See: adisarid.github.io
# Twitter @SaridResearch

#
# This is a Plumber API. In RStudio 1.2 or newer you can run the API by
# clicking the 'Run API' button above.
#
# In RStudio 1.1 or older, see the Plumber documentation for details
# on running the API.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)

source("R/get_startrek_quote.R") # the actual data set we're using and the functions

#* @apiTitle Plumber Star Trek Quote Generator API

#* Return a quote from a startrek character
#* @param character_fl The character you want, e.g., PICARD, DATA, WORF, SISKO, etc.
#* @param series_fl The series you want (the 3 letter abbreviation, i.e., TNG, DS9, VOY, TOS, ENT)
#* @get /startrekquote
function(character_fl = "PICARD", series_fl = c("TNG", "DS9", "VOY", "TOS", "ENT")){
  
  selected_quote <- get_random_quote(str_to_upper(character_fl), str_to_upper(series_fl))
  
  if (is.na(selected_quote)){
    return(list(error = "No quotes with this combination, or invalid parameters."))
  } else {
    plumber::forward()
  }
  
  selected_quote
  
}


# This script shows how to deploy your API on digital ocean.
# This is the quickest and simplest way to go from localhost to cloud, 
#    since everything is ready made in R commands with the analogsea and plumber packages.
# For additional deployment methods, read the plumber documentation.

library(plumber)
library(analogsea)

# required for accessing the droplet:
if (!("ssh" %in% installed.packages())){
  install.packages("ssh")
}

# Provisioning the droplet ----
# get details about options using analogsea::regions()
## DO NOT RUN TWICE...:
plumber_do <- do_provision(name = "startrek-plumber-API-example2",
                           example = FALSE,
                           region = "fra1",
                           size = "2gb")

## if running for the second time use
plumber_do <- as.droplet("startrek-plumber-API-example2")

# Install required R packages ----
install_r_package(plumber_do, "tidyverse")
install_r_package(plumber_do, "jsonlite")

# Actual deployment ----
do_deploy_api(plumber_do, path = "startrek_api",
              localPath = here::here(),
              swagger = T,
              forward = T)

# Configure secure connection TSL ----
# run this code only after adding an A record in your DNS management system 
# which points into the droplet's ip address

my_email <- "adi+letsencrypt@sarid-ins.co.il" # if using this code, replace this with your email address
plumber::do_configure_https(plumber_do, domain = "api.hebrewr.co.il",
                            email = my_email,
                            termsOfService = T,
                            force = F)

# To kill the droplet ----

# droplet_delete(plumber_do)
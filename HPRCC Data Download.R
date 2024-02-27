# scrapes all daily weather data in complete years from active stations in the HPRCC network

library(tidyverse)
library(tidyjson)
library(lubridate)

# list active stations, decode JSON, and save to a file
setwd("~/Desktop/GitHub/Public/data/HPRCC/raw")
system("wget https://awdn2.unl.edu/productdata/get?active=scqc1440 -p -k --random-wait")
active_stations <- read_file("awdn2.unl.edu/productdata/get?active=scqc1440") %>%
  gather_array %>%
  spread_all

saveRDS(active_stations, "active_station_metadata.rds")

file.remove("awdn2.unl.edu/productdata/get?active=scqc1440")

# download data for each station
for (stationid in active_stations$stationid) {
  station_name <- active_stations$name[active_stations$stationid == stationid]
  
  startup <- active_stations$startup[active_stations$stationid == stationid] %>%
    as.POSIXct() %>%
    as.Date()
  
  # round up to the first full year available
  firstyear <- year(startup) + 1

  # acquire through the end of 2023
  lastyear <- 2023
  
  # download data one year at a time to stay under apparent API limits
  station_data <- list()
  for (year in seq(firstyear, lastyear)) {
    start <- str_glue("{year}0101")
    end <- str_glue("{year}1231")
    
    # get daily weather data
    filename <- str_glue("awdn2.unl.edu/productdata/get?name={station_name}&productid=scqc1440&begin={start}&end={end}&units=us&format=csv")
    url <- str_glue('https://{filename}')
    system(as.character(str_glue("wget '{url}' -p -k --random-wait")))
    if (file.exists(filename)) {
      station_data[[year]] <- read_csv(filename, skip=1, show_col_types = F) %>%
        mutate(stationid = stationid) %>%
        filter(TIMESTAMP!="TS")
      
      file.remove(filename)
    }
  }
   
  station_data_all <- bind_rows(station_data) 
  saveRDS(station_data_all, str_glue("{stationid}.rds"))
}
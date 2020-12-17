# Download Environment Canada weather data

# Mirrors the Linux CLI instructions found here: https://drive.google.com/drive/folders/1WJCDEU34c60IfOnG4rv5EPZ4IhhW9vZH

setwd("/mnt/hdd/git/Public/data")

library(tidyverse)

years <- c(2015:2015)
months <- c(5:10)

station <- "50132"

timeframe <- 1 #1 for hourly, 2 for daily

#station list: https://docs.google.com/spreadsheets/d/1MmbCdB16fR0Q6KNA5Q2k4ddnVW9ZzE6AIyC9K1AokhQ/edit#gid=806259678
#use Station ID column

data.list <- list()

for (year in years) {
  for (month in months) {
    index <- str_c(year, month, sep="-")
    download.file(sprintf("https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=%s&Year=%s&Month=%s&Day=14&timeframe=%s&submit= Download+Data", station, year, month, timeframe),
                  method = "wget", extra = "--content-disposition", destfile="temp.csv")
    data.list[[index]] <- read_csv("temp.csv", col_types = cols(.default = "c"))
  }
}

data <- bind_rows(data.list)

if (timeframe==1){
  timestep <- "Hourly"
} else {
  timestep <- "Daily"
}

write_csv(data, str_glue("EnvironmentCanada_Weather_Station{station}_{timestep}_From{min(years)}_To{max(years)}.csv"))

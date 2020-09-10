# Download Environment Canada hourly weather data

# Mirrors the Linux CLI instructions found here: https://drive.google.com/drive/folders/1WJCDEU34c60IfOnG4rv5EPZ4IhhW9vZH

library(tidyr)

years <- c(2015:2015)
months <- c(5:10)

station.code <- "50132"

#station list: https://docs.google.com/spreadsheets/d/1MmbCdB16fR0Q6KNA5Q2k4ddnVW9ZzE6AIyC9K1AokhQ/edit#gid=806259678
#use Station ID column

data.list <- list()

for (year in years) {
  for (month in months) {
    index <- str_c(year, month, sep="-")
    download.file(sprintf("https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=1706&Year=%s&Month=%s&Day=14&timeframe=1&submit= Download+Data", year, month),
                  method = "wget", extra = "--content-disposition", destfile="temp.csv")
    data.list[[index]] <- read_csv("temp.csv", col_types = cols(.default = "c"))
  }
}

data <- bind_rows(data.list)

write_csv(data, str_glue("EnvironmentCanada_Weather_Station{station.code}_From{min(years)}_To{max(years)}.csv"))

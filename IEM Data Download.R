# Download IEM data
library(tidyverse)
library(riem)
library(data.table)
library(lubridate)

# list networks starting with "CO_"
riem_networks() %>% filter(code %like% "CO_")

# list stations in network "CO_ASOS"
co_stations <- riem_stations(network="CO_ASOS")

# make empty directory
dir.create("data", showWarnings = F)

# download raw data then save to file
for (station_id in co_stations$id) {
  if (!file.exists(paste("data/raw/", station_id, ".rds"))) {
    station_metadata <- co_stations %>% filter(id==station_id)
    start_date <- as.Date(station_metadata$archive_begin)
    station_elevation_m <- station_metadata$elevation
    station_data <- riem_measures(station=station_id, date_start=start_date) %>%
      select(station, valid, lon, lat, tmpf, dwpf, relh, sknt, p01i, alti) %>%
      mutate(elevm = station_elevation_m)
    saveRDS(station_data, paste("data/raw/", station_id, ".rds"))
  }
}

#mutate(elevm = station_elevation_m,
#       date = ISOdate(year(valid), month(valid), mday(valid))) %>%
#  pivot_longer(cols=c(-station, -valid, -date)) %>%
#  na.omit() %>%
#  group_by(station, date, name) %>%
#  summarize(value=mean(value))

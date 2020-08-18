# Dependencies----
library(rpostgis)
library(tidyverse)
library(lubridate)
library(sf)
library(ggformula)
library(plotly)
library(htmlwidgets)
library(htmltools)
library(crosstalk)

# Download and Store Data----
gisdata <- readRDS("lake_centroids.rds")

#FILTER LAKES HERE OR YOU WILL GET EVERYTHING#
#filter by lat/lon:
#gisdata <- gisdata %>% 
#  filter(lat_dd > 45 & lat_dd < 45.25) %>%
#  filter(lon_dd < -95 & lon_dd > -95.25)

#filter by name
gisdata <- gisdata %>%
  filter(pw_basin_name=="White Bear")

lake.ids <- gisdata$dowlknum

#scrape csv data and combine into a dataframe
url.prefix <- "https://files.dnr.state.mn.us/cgi-bin/lk_levels_dump.cgi?format=csv&id="
urls <- str_c(url.prefix, lake.ids)
urls.list<- as.list(urls)
mondata.list <- lapply(urls.list, read.table, sep=",", header=T, row.names=NULL, stringsAsFactors=F)
mondata <- as_tibble(bind_rows(mondata.list[lapply(mondata.list, nrow)>0]))
names(mondata) <- c("dowlknum", "elev.ft", "date", "datum")
mondata$date <- as_date(mondata$date)

#remove duplicate rows
mondata <- mondata %>%
  group_by(dowlknum, date,  datum) %>%
  summarize(elev.ft = mean(elev.ft))

mondata <- merge(gisdata[,c("dowlknum", "pw_basin_name")], mondata, by="dowlknum", all=F)

mondata <- mondata %>% arrange(pw_basin_name, dowlknum, date)

# Regenerate Interactive Plot----
#make tidy data
lfdata <- as_tibble(mondata) %>%
  mutate(Year=year(date)) %>%
  select(-datum) %>%
  rename("Lake.ID"="dowlknum", 
         "Lake.Name"="pw_basin_name",
         "Date"="date",
         "Elevation.ft"="elev.ft")

#save data with a timestamp
saveRDS(lfdata, str_glue("lakefinderdata_{format(now(), '%Y%m%d_%H%M%S')}.rds"))

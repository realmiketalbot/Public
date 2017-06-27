#example script that scrapes data from the IEM ASOS download service
#adapted from python code here: https://github.com/akrherz/iem/blob/master/scripts/asos/iem_scraper_example.py
#downloads data for an ASOS station specified below

###USER INPUTS###
iem.wd <- "C:/Data" #download location
date1 <- ISOdate(2005,1,1) #start date in year, month, day format
date2 <- ISOdate(2017,6,26) #end date in year, month, day format
user.network <- c("ASOS")
user.state <- c("IA") #state
user.faaid <- c("SUX") #site FAA identifier - leave empty and a list will print for your reference
#################

library(jsonlite)
library(RCurl)
library(lubridate)
library(stringr)

#create subdirectories
download.wd <- str_c(iem.wd, user.network, user.faaid, sep="/")
if(user.faaid != "") {dir.create(download.wd, recursive=T)}
setwd(download.wd)

service <- "https://mesonet.agron.iastate.edu/cgi-bin/request/asos.py?"
service <- str_c(service, "data=all&tz=Etc/UTC&format=comma&latlon=yes&", sep="")
service <- str_c(service, "year1=", year(date1), "&month1=", month(date1), "&day1=", mday(date1), "&", sep="")
service <- str_c(service, "year2=", year(date2), "&month2=", month(date2), "&day2=", mday(date2), "&", sep="")

states <- c("AK AL AR AZ CA CO CT DE FL GA ")
states <- str_c(states,"HI IA ID IL IN KS KY LA MA MD ")
states <- str_c(states,"ME MI MN MO MS MT NC ND NE NH ")
states <- str_c(states,"NJ NM NV NY OH OK OR PA RI SC ") 
states <- str_c(states,"SD TN TX UT VA VT WA WI WV WY")

states <- unlist(strsplit(states, " "))

networks <- "AWOS"
for (i in 1:length(states)) {
  networks[i+1] <- str_c(states[i], "_ASOS", sep="")
}

if (user.network == "ASOS"){
  networks <- networks[which(networks %in% str_c(user.state, "_", user.network))]
} else {
  networks <- subset(networks %in% str_c(user.network))
}

for (network in networks){
  #get metadata
  uri <- str_c("https://mesonet.agron.iastate.edu/geojson/network/", network, ".geojson", sep="")
  
  data <- url(uri)
  jdict <- fromJSON(data)
  
  for (i in 1:nrow(jdict$features)){
    site <- jdict$features[i,]
    faaid <- site$properties$sid
    if (faaid == user.faaid) {
      sitename <- site$properties$sname
      uri <- str_c(service, "station=", faaid)
      print(str_c("Network:", network, "Downloading:", sitename, faaid, sep=" "))
      data <- url(uri)
      #print(data) #uncomment to print metadata
      datestring1 <- format(date1, "%Y%m%d")
      datestring2 <- format(date2, "%Y%m%d")
      outfn <- str_c(network, "_", faaid, "_", datestring1, "_to_", datestring2, sep="")
      download.file(uri, str_c(outfn, ".txt"), "auto")
    } 
    if (user.faaid == "" & i == 1) {
      print(data.frame(jdict$features$properties[c("sname", "sid")]))
    }
  }
}



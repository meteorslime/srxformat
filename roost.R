## Read in roost locality table
roost <- read.delim(file = "roost.csv", 
  header = T, 
  sep = ",", 
  dec = ".",
  strip.white = T,
  stringsAsFactors = F)

## Format "Date" values in `roost`
roost$Date <- as.POSIXct(roost$Date, "%m/%d/%Y", tz = "America/New_York")

## Save `roost`
save(roost, file = "roost.Rdata")

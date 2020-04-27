## Read in temperature equations
temp.equations <- read.delim(file = "tempequations.txt", 
  header = T, 
  sep = ",",
  dec = ".",
  colClasses = c("numeric", rep("character", 4), rep("numeric", 4)))

## Format "Date" values in `temp.equation`
temp.equations$Date <- as.POSIXct(temp.equations$Date, "%Y-%m-%d", tz = "America/New_York")

## Save `temp.equation`
save(temp.equations, file = "tempequations.Rdata")

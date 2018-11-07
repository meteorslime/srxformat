## Read in sunrise/sunset times and create data frame `suntimes`
suntimes <- read.delim(file = "./Data/suntimes2016.csv", 
    header = T, 
    sep = ",", 
    dec = ".",
    colClasses = c(rep("character", 3)))

## Format date and time
suntimes$Date <- as.POSIXct(suntimes$Date, "%Y-%m-%d", tz = "America/New_York")
suntimes$Rise <- as.POSIXct(paste(suntimes$Date, suntimes$Rise), "%Y-%m-%d %H%M", tz = "America/New_York")
suntimes$Set <- as.POSIXct(paste(suntimes$Date, suntimes$Set), "%Y-%m-%d %H%M", tz = "America/New_York")

## Save
save(suntimes, file = "./Data/suntimes.Rdata")


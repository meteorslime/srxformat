## Data sources
setwd("./Thermoregulation/")

## Read in raw output file, create data frame `hobo`
hoboa <- read.csv(file = "./Data/HoboA_Mod.csv", 
    header = T, 
    sep = ",", 
    dec = ".",
    stringsAsFactors = F)
    
hobob <- read.csv(file = "./Data/HoboB_Mod.csv", 
    header = T, 
    sep = ",", 
    dec = ".",
    stringsAsFactors = F)

hoboc <- read.csv(file = "./Data/HoboC_Mod.csv", 
    header = T, 
    sep = ",", 
    dec = ".",
    stringsAsFactors = F)

## Add "Hobo" and "SN" columns
hoboa$Hobo <- c("A")
hobob$Hobo <- c("B")
hoboc$Hobo <- c("C")

hoboa$SN <- c("10740193")
hobob$SN <- c("10740196")
hoboc$SN <- c("10740195")

## Combine into a single object
hobo <- rbind(hoboa, hobob, hoboc)

rm(hoboa, hobob, hoboc)

## Format "Time"
hobo$Time <- as.POSIXct(paste(hobo$Time), format = "%y-%m-%d %H:%M", tz = "America/New_York")

## Arrange by "Time" and "Hobo"
library(plyr)
hobo <- arrange(hobo, Time, Hobo)

# Reorder columns
hobo <- hobo[c("Hobo", "SN", "Date", "Time", "Temp", "RH", "Dew")]

# Save dataset
save(hobo, file = "./Data/hobo.Rdata")

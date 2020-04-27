## Import airport dataset
airport <- read.delim(file = "./Data/airport.csv", 
  header = T, 
  sep = ",", 
  dec = ".",
  strip.white = T,
  stringsAsFactors = F)

## Format "Time"
airport$Time <- as.POSIXct(paste(airport$Time), format = "%m/%d/%Y %H:%M", tz = "America/New_York")

## Clean up time values by converting each observation to XX:00:00
library(plyr)

airport <- ddply(airport, .(Station), mutate, 
  Time = paste(substring(Time, 0, 13), ":00:00", sep = "")
)

## Format "Time" again
airport$Time <- as.POSIXct(paste(airport$Time), format = "%Y-%m-%d %H:%M:%S", tz = "America/New_York")

## Aggregate mean values for each field between Chatham and Provincetown airports
df1 <- aggregate(Drybulb ~ Time, airport, mean, na.rm = F)
df2 <- aggregate(Wetbulb ~ Time, airport, mean, na.rm = F)
df3 <- aggregate(Dew ~ Time, airport, mean, na.rm = F)
df4 <- aggregate(RH ~ Time, airport, mean, na.rm = F)

## Merge into a single object
airport <- Reduce(function(x, y) {
  merge(x, y, all = T)
  }, 
  list(df1, df2, df3, df4))

rm(df1, df2, df3, df4)

## Create a new data frame for per-minute time resolution
df <- data.frame(Time = seq(from = min(airport$Time), to = max(airport$Time), by = "min"))

df$Hour <- as.POSIXct(paste(df$Time), format = "%Y-%m-%d %H", tz = "America/New_York")

t <- match(df$Hour, airport$Time)

## Add in values
df$Drybulb <- airport$Drybulb[t]
df$Wetbulb <- airport$Wetbulb[t]
df$Dew <- airport$Dew[t]
df$RH <- airport$RH[t]

rm(t)

## Replace hour-resolution data with minute-resolution
airport <- df

airport$Hour <- NULL

rm(df)

## Sort by time
library(plyr)

airport <- arrange(airport, Time)

# Save aggregated dataset
save(airport, file = "./Data/airport.Rdata")

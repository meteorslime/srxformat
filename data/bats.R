## Read in bat table
bats <- read.delim(file = "bats.csv", 
  header = T, 
  sep = ",", 
  dec = ".",
  strip.white = T,
  stringsAsFactors = F)

## Format identifier fields
bats$Freq <- as.character(bats$Freq)
bats$Freq[which(bats$Freq == "148.96")] <- "148.960"

bats$Species <- as.factor(bats$Species)

bats$Repro <- as.factor(bats$Repro)

## Format date fields
bats$CS_Date <- as.POSIXct(bats$CS_Date, "%m/%d/%Y", tz = "America/New_York")
bats$FL_Date <- as.POSIXct(bats$FL_Date, "%m/%d/%Y", tz = "America/New_York")
bats$LL_Date <- as.POSIXct(bats$LL_Date, "%m/%d/%Y", tz = "America/New_York")

## Save `bats`
save(bats, file = "bats.Rdata")

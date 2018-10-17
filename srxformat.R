## Test dataset
#setwd("./Thermoregulation")
#file <- "./Data/367_2016-07-12.TXT" # 64. MYSE.191 (2016-07-09)

## Function `SRXFormat`
SRXFormat <- function(file = file) {

## Load temperature equations  
load("tempequations.Rdata")

## Read in SRX output file and skip to data section
srx.output <- read.delim(file = file, 
  header = T, 
  sep = "", 
  dec = ".", 
  skip = grep("Beeper Records", readLines(file)), 
  strip.white = T,
  stringsAsFactors = F)

## Delete last line
srx.output <- srx.output[-nrow(srx.output), ]

## Delete "Power" and "Antenna" fields
srx.output$Antenna <- NULL
srx.output$Power <- NULL

## Read in active scan table section of SRX output file
srx.scan.table <- read.delim(file = file, 
  header = T, 
  sep = "", 
  stringsAsFactors = F,
  skip = max(grep("Active scan_table", readLines(file))), 
  nrows = max(grep("Noise Blank Level", readLines(file))) - max(grep("Active scan_table", readLines(file))) - 3)

## Replace "Channel" in `srx.output` with the matching frequency from `srx.scan.table`
ch <- match(srx.output$Channel, srx.scan.table$CHANNEL)

srx.output$Freq <- as.character(srx.scan.table$FREQUENCY[ch])

rm(ch)

srx.output$Channel <- NULL

## Format "Date" and "Time" values in `srx.output` as POSIXct objects
srx.output$Date <- as.POSIXct(srx.output$Date, "%m/%d/%y", tz = "America/New_York")
srx.output$Time <- as.POSIXct(paste(srx.output$Date, srx.output$Time), "%Y-%m-%d %H:%M:%S", tz = "America/New_York")

## Calculate milliseconds-per-beat from "BPM" and add column "msPB"
library(plyr)
srx.output <- ddply(srx.output, .(Time), mutate,
  msPB = 60000 / BPM
)

## Look up the corresponding equation and add a column in `srx.output` for each term
srx.output$x1 <- temp.equations$A[match(srx.output$Freq, temp.equations$Freq)]
srx.output$x2 <- temp.equations$B[match(srx.output$Freq, temp.equations$Freq)]
srx.output$x3 <- temp.equations$C[match(srx.output$Freq, temp.equations$Freq)]
srx.output$x4 <- temp.equations$D[match(srx.output$Freq, temp.equations$Freq)]

## Calculate body temperature for each observation and add to column "Tsk"
library(plyr)
srx.output <- ddply(srx.output, .(Time), mutate,
  Tsk = (x1 + x2*msPB + x3*msPB^2 + x4*msPB^3)
)

## Cleanup
srx.output$BPM <- NULL
srx.output$msPB <- NULL
srx.output$x1 <- NULL
srx.output$x2 <- NULL
srx.output$x3 <- NULL
srx.output$x4 <- NULL

## Add "BatID" column in `srx.output`
# Note: If the dataset contains multiple individuals identified by the same frequency, this step needs to be modified, because it currently only matches the frequency to the first corresponding bat ID in `temp.equations`. Since this occurred only once in my dataset, I chose to simply correct it manually instead of implementing a conditional statement here.
srx.output$BatID <- temp.equations$BatID[match(srx.output$Freq, temp.equations$Freq)]

# Delete "Freq" column in `srx.output`
srx.output$Freq <- NULL

# Add a column for source file in `srx.output`
srx.output$Sourcefile <- file

# Reorder columns in `srx.output`
srx.output <- srx.output[c("BatID", "Date", "Time", "Sourcefile", "Tsk")]

## Message
message("\n", "Successfully formatted ", file, appendLF = TRUE)
flush.console()

# Function `SRXFormat` end
return(srx.output)
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

## ## ##  SRXMerge  ## ## ##

## Test dataset
#setwd("./Thermoregulation")
#srx.files <- list.files(path = "./Data/", pattern = "367_2016-07-12.TXT") # 64. MYSE.191 (2016-07-09)
#srx.files <- list.files(path = "./Data/", pattern = "36*")
#pattern = c("36*")

## Turn off warnings for pbapply
#w <- getOption("warn")
#options(warn = -1)

#library(pbapply)
#library(plyr)

#options(warn = w)
#rm(w)

## Function `SRXMerge` begin
SRXMerge <- function (pattern) {

## Get list of file names from working directory
#pattern <- c("36*")
srx.files <- list.files(pattern = pattern)

## Message
message("Formatting and merging ", length(srx.files), " files", appendLF = TRUE)
flush.console()

## Sink output to Merge Report
sink("mergereport.txt")

## Print list of files loaded
cat("SRX output files read: ", length(srx.files), "\n\n", sep = "")
for (i in 1:length(srx.files)) {
  cat(srx.files[i])
  cat("\n")
}
rm(i)
cat("\n")

## Close sink
sink()

## Run batched files through `SRXFormat` and create list `srx.data.list`
library(pbapply)
srx.data.list <- pblapply(srx.files, SRXFormat)

## Merge all objects in `srx.data.list` into a new data frame `srx.data`, using Reduce to merge > 2 objects at once
srx.data <- Reduce(function(x, y) {
  merge(x, y, all = T)
  }, 
  srx.data.list)

## Correct assignment of BatID for EPFU.909
srx.data$BatID[which(
  srx.data$BatID == "MYSE.909" & srx.data$Date >= "2016-08-01")] <- "EPFU.909"

## Load `roost.locality`
load("roost.Rdata")

## Import locality info from `roost.locality` (doesn't change by date)
srx.data <- merge(srx.data, roost, by = c("BatID", "Date"), all.x = T, all.y = F)

## Reopen merge report and sink more output
sink("mergereport.txt", append = T)

## Print list of frequencies
cat("Frequencies recorded in this dataset: ", length(unique(srx.data$BatID)), "\n\n", sep = "")
for (i in 1:length(unique(srx.data$BatID))) {
  cat(as.character(unique(srx.data$BatID)[i]))
  cat("\n")
}
rm(i)
cat("\n")

## Print data summary
library(plyr)
srx.table <- ddply(
  srx.data, .(BatID, Date, LocID), summarize, 
    Address = unique(Address), 
    Begin = format(min(Time), "%H:%M:%S"), 
    End = format(max(Time), "%H:%M:%S"), 
    Samples = length(Date), 
    Sourcefiles = length(unique(Sourcefile)), 
    Filenames = toString(unique(Sourcefile))
)

## Details for merge report
cat("Total observations: ", nrow(srx.data), "\n", sep = "")
cat("Number of bat-days: ", nrow(srx.table), "\n", sep = "")
#cat("EPFU bat-days: ", nrow(srx.table[which(srx.table$Species == "EPFU"]), "\n", sep = "")
#cat("MYSE bat-days: ", nrow(srx.table[which(srx.table$Species == "MYSE"]), "\n", sep = "")
cat("Number of unique roost locations: ", length(unique(srx.table$LocID)), "\n", sep = "")
cat("\n")
#cat("File created: srxdata0.Rdata\n", sep = "")
#cat("\n")

## Close sink
sink()

## Message
message("Success!\nMerge report created in directory:\n", getwd(), appendLF = TRUE)
flush.console()

## Print data summary (console only)
library(plyr)
cat("\nNumber of observations per day:\n\n")
print(ddply(srx.data, .(BatID, Date), summarize, 
  Samples = length(Date)))
cat("\nTotal: ", nrow(srx.data), "\n")
cat("\n")

## Organize
library(plyr)
srx.data <- arrange(srx.data, BatID, Date)

srx.data <- srx.data[c("BatID", "Date", "Time", "LocID", "Substrate", "Address", "SRX", "Hobo", "Sourcefile", "Tsk")]

## Save
#save(srx.data, file = "./Data/srxdata0.Rdata")
#save(srx.table, file = "./Data/srxtable0.Rdata")

## Write to file
#write.csv(srx.data, file = "./Results/srxdata0.csv")
#write.csv(srx.table, file = "./Results/srxtable0.csv")

## Cleanup
rm(srx.data.list, srx.files, srx.table)

## Function end
return (srx.data)
}

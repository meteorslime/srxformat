# srxformat
Format, convert, and combine multiple SRX-800 datalogger output files (and another file containing supplementary information) into a single dataset.

The Lotek SRX-800 datalogger scans for pre-programmed VHF frequencies and records signal characteristics (e.g. pulse rate) that can later be converted into measurements of the animal's skin surface temperature. This conversion is performed using an equation provided by the manufacturer, which is unique to each transmitter. The datalogger's raw output consists of tab-separated plaintext files with a .TXT extension.

This repo contains scripts that are intended to (mostly) automate the process of formatting these raw output files as R objects, converting the pulse rate to temperature, merging the resulting objects into a single data structure, and performing some other housekeeping tasks (e.g. removing duplicate records, which occur when the datalogger's internal storage is not cleared after a download) to make the dataset available for manipulation and analysis in R.

In addition to the output files themselves, some supplemental information is needed to complete the dataset: (1) a file containing the unique temperature equation for each transmitter; and (2) a way to associate the labels for individual animal subjects with their respective transmitter frequencies, since the raw output data is only assocaited with a frequency number (which can be problematic if, as in my study, transmitters are re-used between individuals).

Before running the script, I prepared a file called "tempequations.txt" with transmitter frequency number as the identifier, columns x1 through x4 containing the terms for the quadratic equation, and an additional column with the individual animal label ("BatID"), then converted this into an R object. With that done, all that's left is to place the raw datalogger output files into a single directory and run the script.

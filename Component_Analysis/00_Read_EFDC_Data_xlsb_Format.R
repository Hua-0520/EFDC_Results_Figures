#Required libraries-------------------------------------
library(excel.link)
library(plyr)
library(tidyr)

#Working directories------------------------------------
wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Data file name----------------------------------------
# file_name <- c('EFDC_Template_Development_Data.xlsb') provided by the scenario run file
worksheets <- c('WWTP', 'Unknown', 'Stormwater', 'CSOs', 'Upstream')

sheet_names <- c('WWTP', 'Unknown', 'Stormwater', 'CSOs', 'Upstream', 'E. coli')
df_names <- c('WWTP', 'Unknown', 'Stormwater', 'CSOs', 'Upstream', 'Ecoli')

#Functions---------------------------------------------
#Wrapper for xl.read.file from the excel.link package
read_in_files <-function(x, file_name){
  xl.read.file(filename = file_name
               , xl.sheet = x
               , header = TRUE
               , top.left.cell = 'A10')
}

#Load lookup tables------------------------------------
setwd(wd_lookup)
lookup_station <- read.csv(file = 'WQ_Station_Lookup.csv', stringsAsFactors = F)

#Load data---------------------------------------------
setwd(wd_data)

#Read in the data as a list of data frames
#This is really slow (>10 minutes)
data <- xl.read.file(filename = file_name_efdc, xl.sheet = 1, header = T, top.left.cell = 'A10')

names(data) <- c('datetime', lookup_station[ ,3])

#Replace values of zero with 0.01
data[data == 0] <- 0.01


#Save and RDS file if one doesn't exist
setwd(wd_data)
if(!file.exists(rds_name_efdc)){saveRDS(object = dat_complete, file = rds_name_efdc)}

#Temp comment
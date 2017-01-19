#Required libraries-------------------------------------
library(excel.link)
library(plyr)
library(tidyr)

#Working directories------------------------------------
wd_data <- c('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/RVAJR_C01')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Data file name----------------------------------------
# scenario_name <- c()
# file_name <- c('EFDC_export_120616-1150.xlsb')
file_name <- c('EFDC_Template_Development_Data.xlsb')
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

#This is slow (~2-3 minutes)
# df <- xl.read.file(filename = 'EFDC_export_120616-1150.xlsb'
#                    , xl.sheet = 'WWTP'
#                    , header = TRUE
#                    , top.left.cell = 'A10')

# names(df) <- c('datetime', lookup_station[ , 3])

#Read in the data as a list of data frames
#This is slow (~2-3 minutes)
data <- lapply(sheet_names, read_in_files, file_name = file_name)

#Name the data frames
names(data) <- df_names

#Update column names in each list
data <- lapply(data, setNames, nm = c('datetime', lookup_station[ , 3]))

#Combine list of data frames into a single dataframe
dat_complete <- ldply(data, .id = 'component')

#Replace values of zero with 0.001
dat_complete[dat_complete == 0] <- 0.01



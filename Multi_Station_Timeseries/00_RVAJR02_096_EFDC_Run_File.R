#Libraries----------------------------------
library(excel.link); library(plyr); library(dplyr); library(ggplot2); library(tidyr); library(lubridate); library(stringr)
library(rattle); library(scales); library(forcats); library(gridExtra)

#Required Parameters------------------------
scenario_name <- c('RVAJR02_096')

#Working directories------------------------
wd_script_src <- ('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Multi_Station_Timeseries')
wd_efdc_data_src <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')

#Parameters used in 00_Read_EFDC_Data_xlsb_Format.R
file_name_efdc <- c('EFDC_export_020917-1308.xlsb')
rds_name_efdc <- paste(scenario_name, '.rds', sep = '')

#Run---------------------------------------

#Load results from normal EFDC run that go with the component data
#Check if a faster loading RDS file exists, if not then load from xlsb format
setwd(wd_efdc_data_src)
if(file.exists(rds_name_efdc)){
  dat_efdc <- readRDS(file = rds_name_efdc)
}else{
  setwd(wd_script_src)
  source('01_Read_EFDC_Data_xlsb_Format.R')
}

#Load WQ Data
setwd(wd_script_src)
source('01_Read_Water_Quality_csv_Format.R')

#Create Figures
setwd(wd_script_src)
source('02_Time_Series_with_Data.R')

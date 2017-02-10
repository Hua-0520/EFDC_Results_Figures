#Libraries----------------------------------
library(excel.link); library(plyr); library(dplyr); library(ggplot2); library(tidyr); library(lubridate); library(stringr)
library(rattle); library(scales); library(forcats); library(gridExtra); library(RColorBrewer)

#Required Parameters------------------------
scenario_name <- c('RVAJR02_079')

#Working directories------------------------
wd_script_src <- ('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Longitudinal_Profiles')
wd_efdc_data_src <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')
wd_output <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/', scenario_name, sep = '')

#Parameters used in 00_Read_EFDC_Data_csv_Format.R
file_name_efdc <- c('EFDC_export_012517-1201.csv')
rds_name_efdc <- paste(scenario_name, '_longitudinal_profile_results.rds', sep = '')
geomean_months <- c('2011-12', '2013-06', '2013-07', '2013-12') #This line comes from GEOMEAN_Standard_Violations.txt

#Parameters used in Downstream_Boundary_STV.R
##None

#Run---------------------------------------

#Load results from normal EFDC run that go with the component data
#Check if a faster loading RDS file exists, if not then load from xlsb format
setwd(wd_efdc_data_src)
if(file.exists(rds_name_efdc)){
  dat_efdc <- readRDS(file = rds_name_efdc)
}else{
  setwd(wd_script_src)
  source('01_Read_EFDC_Longitudinal_Data_csv_Format.R')
}

#Create longitudinal plot
setwd(wd_script_src)
source('02_Create_Longitudinal_Plot.R')

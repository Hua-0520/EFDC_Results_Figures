#Libraries----------------------------------
library(excel.link); library(plyr); library(dplyr); library(ggplot2); library(tidyr); library(lubridate); library(stringr)
library(rattle); library(scales); library(forcats); library(gridExtra)

#Required Parameters------------------------
scenario_name <- c('RVAJR02_098')
component_scenario_name <- c('RVAJR_C06')

#Working directories------------------------
wd_script_src <- ('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Component_Analysis')
wd_efdc_data_src <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')
wd_component_data_src <- paste('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/', component_scenario_name, sep = '')

#Parameters used in 00_Read_Component_Data_xlsb_Format.R
file_name_component <- c('EFDC_export_021717-0829.xlsb')
rds_name_component <- paste(component_scenario_name, '.rds', sep = '')
sheet_names <- c('RVAJR_C06 (WWTP)', 'RVAJR_C06 (Unknown)'
                 , 'RVAJR_C06 (Stormwater)', 'RVAJR_C06 (CSOs)'
                 , 'RVAJR_C06 (Upstream)')
df_names <- c('WWTP', 'Unknown', 'Stormwater', 'CSOs', 'Upstream')

#Parameters used in 00_Read_EFDC_Data_xlsb_Format.R
file_name_efdc <- c('EFDC_export_020917-1309.xlsb')
rds_name_efdc <- paste(scenario_name, '.rds', sep = '')

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
  source('01_Read_EFDC_Data_xlsb_Format.R')
}

#Load Component Data
#Check if a faster loading RDS file exists, if not then load from xlsb format
setwd(wd_component_data_src)
if(file.exists(rds_name_component)){
  dat_complete <- readRDS(file = rds_name_component)
}else{
  setwd(wd_script_src)
  source('01_Read_Component_Data_xlsb_Format.R')
}

#Prep EFDC results for inclusion into the WQSs
setwd(wd_script_src)
source('02_Summarize_EFDC_Output.R')

#Print STV plot
setwd(wd_script_src)
source('03_Downstream_Boundary_STV.R')

#Print Geomean plot
setwd(wd_script_src)
source('03_Downstream_Boundary_GEOMEAN.R')
#Required Parameters------------------------
scenario_name <- c('RVAJR02_079')
component_scenario_name <- c('RVAJR_C01')

#Working directories------------------------
wd_script_src <- ('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Component_Analysis')
wd_component_data_src <- paste('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/', component_scenario_name, sep = '')

#Parameters used in 00_Read_Component_Data_xlsb_Format.R
file_name_component <- c('EFDC_Template_Development_Data.xlsb')
rds_name_component <- paste(scenario_name, '_test_data.rds', sep = '')

#Parameters used in 00_Read_EFDC_Data_xlsb_Format.R
file_name_efdc <- c('EFDC_export_011917-1631.xlsb')
rds_name_efdc <- paste(scenario_name, '.rds', sep = '')

#Parameters used in Downstream_Boundary_STV.R
##None

#Run---------------------------------------

#Load results from normal EFDC run that go with the component data
#Check if a faster loading RDS file exists, if not then load from xlsb format
setwd(wd_component_data_src)
if(file.exists(rds_name_efdc)){
  dat_complete <- readRDS(file = rds_name)
}else{
  setwd(wd_script_src)
  source('00_Read_EFDC_Data_xlsb_Format.R')
}

#Load Component Data
#Check if a faster loading RDS file exists, if not then load from xlsb format
setwd(wd_data_src)
if(file.exists(rds_name_component)){
  dat_complete <- readRDS(file = rds_name)
}else{
  setwd(wd_script_src)
  source('00_Read_Component_Data_xlsb_Format.R')
}

#Print STV plot
setwd(wd_script_src)
source('Downstream_Boundary_STV.R')

#Print Geomean plot
setwd(wd_script_src)
source('Downstream_Boundary_GEOMEAN.R')
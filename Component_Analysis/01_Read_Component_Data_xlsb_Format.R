#Working directories------------------------------------
wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

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
setwd(wd_component_data_src)

#Read in the data as a list of data frames
#This is slow (~2-3 minutes)
data <- lapply(sheet_names, read_in_files, file_name = file_name_component)

#Name the data frames
names(data) <- df_names

#Update column names in each list
data <- lapply(data, setNames, nm = c('datetime', lookup_station[ , 3]))

#Combine list of data frames into a single dataframe
dat_complete <- ldply(data, .id = 'component')

#Replace values of zero with 0.01
dat_complete[dat_complete == 0] <- 0.01

setwd(wd_component_data_src)
if(!file.exists(rds_name_component)){saveRDS(object = dat_complete, file = rds_name_component)}

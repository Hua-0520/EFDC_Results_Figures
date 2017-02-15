#Working directories------------------------------------
wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Load lookup tables------------------------------------
setwd(wd_lookup)
lookup_station <- read.csv(file = 'WQ_Station_Lookup.csv', stringsAsFactors = F)

#Load data---------------------------------------------
setwd(wd_data)

#Read in the data as a list of data frames
#This is really slow (2-3 minutes?)
dat_efdc <- xl.read.file(filename = file_name_efdc, xl.sheet = 1, header = T, top.left.cell = 'A10')

names(dat_efdc) <- c('datetime', lookup_station[ ,3])

#Replace values of zero with 0.01
dat_efdc[dat_efdc == 0] <- 0.01


#Save and RDS file if one doesn't exist
setwd(wd_data)
if(!file.exists(rds_name_efdc)){saveRDS(object = dat_efdc, file = rds_name_efdc)}

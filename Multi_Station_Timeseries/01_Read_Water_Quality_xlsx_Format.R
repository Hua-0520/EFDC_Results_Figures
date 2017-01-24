#Working directories------------------------------------
# wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Load lookup tables------------------------------------
setwd(wd_lookup)
lookup_station <- read.csv(file = 'WQ_Station_Lookup.csv', stringsAsFactors = F)

#Filter lookup station data----------------------------
stations_of_int <- c(753, 840, 641, 576, 574, 572)
calibration_stations <- lookup_station %>% filter(StationID %in% stations_of_int)

station_nm_of_int <- calibration_stations$Name %>% as.factor(.)

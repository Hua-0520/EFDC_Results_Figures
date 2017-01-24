#Working directories------------------------------------
# wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Load lookup tables------------------------------------
setwd(wd_lookup)
lookup_station <- read.csv(file = 'WQ_Station_Lookup.csv', stringsAsFactors = F)
names(lookup_station) <-normVarNames(names(lookup_station))

lookup_station$station_no <- lookup_station$station_id

#Filter lookup station data----------------------------
stations_of_int <- c(753, 840, 641, 576, 574, 572)
calibration_stations <- lookup_station %>% filter(station_id %in% stations_of_int)

setwd(wd_lookup)
dat_wq <- read.csv(file = 'WQ_Data_from_DB.csv')
names(dat_wq) <- normVarNames(names(dat_wq))
dat_wq <- dat_wq %>% filter(station_no %in% stations_of_int)

#Adding in the station names and the EFDC grid IDs
dat_wq <- left_join(dat_wq, lookup_station)

dat_wq$date_time <- mdy_hm(dat_wq$date_time)

dat_wq <- dat_wq %>% select(date_time, station_no, result, nd_qualifier, grid_id
                            , station_id, station = name)

dat_wq$year <- year(dat_wq$date_time)
dat_wq <- dat_wq %>% filter(year > 2010 & year < 2014)
dat_wq$nd_qualifier <- fct_recode(dat_wq$nd_qualifier, 'Detect' = 'D', 'Non-Detect' = 'ND')

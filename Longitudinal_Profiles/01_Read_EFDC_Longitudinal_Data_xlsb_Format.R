#Working directories------------------------------------
wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Load lookup tables------------------------------------
# setwd(wd_lookup)
# lookup_station <- read.csv(file = 'WQ_Station_Lookup.csv', stringsAsFactors = F)

#Load data---------------------------------------------
setwd(wd_data)

#Functions---------------------------------------------
#http://stackoverflow.com/questions/2602583/geometric-mean-is-there-a-built-in
gm_mean <- function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

#Read in the data as a list of data frames
#This is really slow (2-3 minutes?)
header_efdc <- read.csv(file = file_name_efdc, header = T, skip = 2, nrows = 5, stringsAsFactors = F)
efdc_j_grid <- header_efdc[3, 2:2083] %>% unlist(.)

dat_efdc <- read.csv(file = file_name_efdc, header = T, skip = 9, stringsAsFactors = F)
dat_efdc[ , 2:2083] <- lapply(dat_efdc[ , 2:2083], as.numeric)

#Format EFDC longitudinal data
names(dat_efdc) <- normVarNames(names(dat_efdc))
dat_efdc$date_time <- mdy_hm(dat_efdc$date_time)
dat_efdc$year_month <- with(dat_efdc, paste(year(date_time), '-'
                                                , str_pad(month(date_time), width = 2, side = 'left', pad = '0')
                                                , sep = ''))
dat_efdc <- dat_efdc %>% 
  filter(year_month %in% geomean_months)

names_efdc <- names(dat_efdc)

check <- dlply(dat_efdc, 'year_month', identity)
c <- lapply(check, gm_mean)

check <- dat_efdc %>% group_by(year_month) %>% lapply(dat_efdc[ , 2:2083], gm_mean)




geomean <- lapply(dat_efdc[ , ])



check <- gather(dat_efdc, key = parameter, value = result, 2:2083)
check$cell_j_grid <- efdc_j_grid

check2 <- check %>% group_by()


dat_efdc_long <- gather(dat_efdc, )




names(dat_efdc) <- c('datetime', lookup_station[ ,3])

#Replace values of zero with 0.01
dat_efdc[dat_efdc == 0] <- 0.01


#Save and RDS file if one doesn't exist
setwd(wd_data)
if(!file.exists(rds_name_efdc)){saveRDS(object = dat_efdc, file = rds_name_efdc)}

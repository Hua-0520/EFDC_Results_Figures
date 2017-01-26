#Load data---------------------------------------------
setwd(wd_efdc_data_src)
# #This is really slow (2-3 minutes?)
# header_efdc <- read.csv(file = file_name_efdc, header = T, skip = 2, nrows = 5, stringsAsFactors = F)
# efdc_j_grid <- header_efdc[3, 2:2083] %>% unlist(.)

dat_efdc <- read.csv(file = file_name_efdc, header = T, skip = 9, stringsAsFactors = F)

#If this is necessary then you likely included numbers with commas (e.g. 1,100)
# dat_efdc[ , 2:2083] <- lapply(dat_efdc[ , 2:2083], as.numeric)

#Format EFDC longitudinal data
names(dat_efdc) <- normVarNames(names(dat_efdc))
dat_efdc$date_time <- mdy_hm(dat_efdc$date_time)
dat_efdc$year_month <- with(dat_efdc, paste(year(date_time), '-'
                                                , str_pad(month(date_time), width = 2, side = 'left', pad = '0')
                                                , sep = ''))
dat_efdc <- dat_efdc %>% filter(year_month %in% geomean_months)

#Save and RDS file if one doesn't exist
setwd(wd_efdc_data_src)
if(!file.exists(rds_name_efdc)){saveRDS(object = dat_efdc, file = rds_name_efdc)}

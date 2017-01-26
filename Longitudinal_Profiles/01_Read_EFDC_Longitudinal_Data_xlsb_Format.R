#Working directories------------------------------------
wd_data <- paste('W:/RICHCWA/WinModel/EFDC/RICHCWA_Grid02/', scenario_name, sep = '')
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Load EFDC J Grid to miles table------------------------------------
setwd(wd_lookup)
grid_location <- read.csv(file = 'EFDC_J_Grid_to_River_Mile.csv', stringsAsFactors = F)

#Load data---------------------------------------------


#Functions---------------------------------------------
#http://stackoverflow.com/questions/2602583/geometric-mean-is-there-a-built-in
gm_mean <- function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm = na.rm) / length(x))
}

discontinuity_check <- function(x){
  ifelse(x <= 1, x <- NA, x <- x)
}

#Load data---------------------------------------------
setwd(wd_data)
#This is really slow (2-3 minutes?)
header_efdc <- read.csv(file = file_name_efdc, header = T, skip = 2, nrows = 5, stringsAsFactors = F)
efdc_j_grid <- header_efdc[3, 2:2083] %>% unlist(.)

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

names_efdc <- names(dat_efdc)

#Dim new data frame for geomean results
dat_geomean <- data.frame(matrix(nrow = length(geomean_months), ncol = length(names(dat_efdc)) - 2))
names(dat_geomean) <- names_efdc[2:2083]

#Calculate monthly geometric means for each cell
for(i in 1:length(geomean_months)){
  df <- dat_efdc %>% filter(year_month == geomean_months[i])
  
  gm <- lapply(df[ , 2:2083], gm_mean)
  
  dat_geomean[i, ] <- gm
}

#Add in year_month names and bump it to the front
dat_geomean$year_month <- geomean_months
dat_geomean <- dat_geomean %>% select(year_month, c(1:2083))

#Convert from wide format to long format for grouping
dat_geomean_wide <- gather(dat_geomean, column, result, 2:2083)

dat_geomean_wide <- dat_geomean_wide %>% arrange(year_month)

#Add in the J Grid value from the header
dat_geomean_wide$j_grid_no <- header_efdc[3, c(2:2083)] %>% 
  unlist(.) %>% 
  rep(., times = 4)

#Select the maximum geomean for each J Grid value 
##(selecting the cell with the least compliant water)
dat <- dat_geomean_wide %>% 
  group_by(year_month, j_grid_no) %>% 
  dplyr::summarise(max_j_geomean = max(result))

dat <- left_join(dat, grid_location)

check <- lapply(dat$max_j_geomean, discontinuity_check) %>% unlist(.)
dat$check <- check

#Plot-------------------------------------------------
for(i in 1:length(geomean_months)){
  df <- dat %>% filter(year_month == geomean_months[i])
  
  x <- ggplot(data = df, aes(x = station_miles, y = check)) +
    geom_line() +
    scale_x_continuous(limits = c(0, 22)) +
    scale_y_continuous(limits = c(0, 300), breaks = seq(0, 300, by = 50))
}


#Save and RDS file if one doesn't exist
setwd(wd_data)
if(!file.exists(rds_name_efdc)){saveRDS(object = dat_efdc, file = rds_name_efdc)}

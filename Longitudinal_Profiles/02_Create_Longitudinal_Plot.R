#Working directories------------------------------------
wd_lookup <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts')

#Load EFDC J Grid to miles table------------------------------------
setwd(wd_lookup)
grid_location <- read.csv(file = 'EFDC_J_Grid_to_River_Mile.csv', stringsAsFactors = F)

#Load vector of J Grid cells with wetting/drying issues
j_grid_na <- read.csv(file = 'WQ_Model_J_Cells_Wet-Dry.csv'
                      , header = F, stringsAsFactors = F) %>% 
  unlist(.)

#Create vector of locations
loc <- c(4.44, 11.40, 17.71, 6.82, 18.50)
loc_labs <- c('Huguenot Bridge', '14th Street Bridge', 'D/S City Limit'
              , 'James River Park', 'Falling Creek')
df_loc <- data.frame(name = as.factor(loc_labs), x_loc = loc, y_loc = rep(395, 5))

#Create list of j grid cell values
setwd(wd_efdc_data_src)
header_efdc <- read.csv(file = file_name_efdc, header = T, skip = 2, nrows = 5, stringsAsFactors = F)
efdc_j_grid <- header_efdc[3, 2:2083] %>% unlist(.)

#Functions---------------------------------------------
#http://stackoverflow.com/questions/2602583/geometric-mean-is-there-a-built-in
gm_mean <- function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm = na.rm) / length(x))
}

#Data processing---------------------------------------
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
  rep(., times = length(unique(dat_geomean_wide$year_month))) #Repeat for number of months in violation

#Select the maximum geomean for each J Grid value 
##(selecting the cell with the least compliant water)
dat <- dat_geomean_wide %>% 
  group_by(year_month, j_grid_no) %>% 
  dplyr::summarise(max_j_geomean = max(result))

dat <- left_join(dat, grid_location)

#Remove geomean values for cells with wetting/drying issues
dat <- dat %>% filter(!(j_grid_no %in% j_grid_na))

#Plot-------------------------------------------------
cc <- brewer.pal(n = length(geomean_months), name = 'Set2')
cc[length(geomean_months) + 1] <- 'red'

x <- ggplot(data = dat, aes(x = station_miles, y = max_j_geomean, color = year_month)) +
  geom_line(lwd = 1.5) +
  geom_hline(aes(yintercept = 126, color = factor('WQS'))
             , show.legend = T) +
  geom_vline(xintercept = loc, linetype = 'dashed') +
  geom_text(data = df_loc, aes(x = loc - 0.3, y = 290, label = loc_labs)
            , angle = 90, hjust = 'left', inherit.aes = F) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 22)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 400), breaks = seq(0, 300, by = 50)) +
  scale_color_manual(values = cc) +
  scale_linetype_manual(values = c(rep(1, length(geomean_months)), 2)) +
  labs(x = 'Distance Downstream (mi)', y = 'Geometric Mean (CFU/100 mL)') +
  theme_bw() +
  theme(legend.title = element_blank()
        , legend.position = 'top'
        , legend.key.size = unit(0.2, 'in')) +
  theme(legend.title = element_blank()
        , legend.position = 'top'
        , legend.direction = 'horizontal'
        , legend.box = 'horizontal'
        , legend.key = element_blank()) +
  theme(strip.background = element_blank()) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

setwd(wd_output)
ggsave(filename = paste(scenario_name, '_GEOMEAN_longitudinal_profile.png', sep = ''), plot = x
       , width = 9, height = 6, units = 'in')
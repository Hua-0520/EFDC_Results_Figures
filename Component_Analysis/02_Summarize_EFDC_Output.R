#Set working directories---------------------------------------
wd_print <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/'
                  , scenario_name, sep = '')

#Format data---------------------------------------------------
dat <- dat_efdc %>% select(1,6)
names(dat) <- normVarNames(names(dat))

dat$year_month <- with(dat, paste(year(datetime), '-'
                                  , str_pad(month(datetime), width = 2, side = 'left', pad = '0')
                                  , sep = ''))

#Calculate which months violate the STV standard---------------
dat_monthly_stv_std_efdc <- dat %>% 
  group_by(year_month) %>% 
  dplyr::summarise(ct = n(), gtr_235_ct = sum(downstream_boundary > 235)) %>% 
  mutate(perc_235_violation_efdc = gtr_235_ct / ct * 100) %>% 
  select(year_month, perc_235_violation_efdc)

#temporary addition (17 months)
# dat_stv_check <- dat_monthly_stv_std_efdc %>% filter(perc_235_violation > 10)

#Calculate which months violate the geometric mean standard-----
dat_monthly_geomean_efdc <- dat %>% group_by(datetime) %>% 
  mutate(ln_total = log(downstream_boundary))
  
dat_monthly_geomean_efdc <- dat_monthly_geomean_efdc %>% group_by(year_month) %>% 
  dplyr::summarise(total_efdc = exp(mean(ln_total)))

#temporary addition (4 months)
# dat_geomean_check <- dat_monthly_geomean_efdc %>% filter(total > 126)

#Calculate the total # of CFU above the monthly geometric mean
#for the percent improvement metric for the calculator
pct_improve_metric <- dat_monthly_geomean_efdc %>% 
  filter(total_efdc > 126) %>% 
  group_by(year_month) %>% 
  dplyr::summarise(ct_above_std = total_efdc - 126)

pct_improvement_metric_cfu <- sum(pct_improve_metric$ct_above_std)

setwd(wd_print)
write.csv(pct_improvement_metric_cfu, file = paste(scenario_name, '_total_CFU_from_GEOMEAN_standard.csv'
                                                   , sep = ''), row.names = F)

#Remove the source data after calculating WQSs
rm(dat)

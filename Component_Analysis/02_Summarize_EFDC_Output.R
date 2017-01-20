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
  mutate(perc_235_violation = gtr_235_ct / ct * 100) %>% 
  select(year_month, perc_235_violation)

#temporary addition (17 months)
dat_stv_check <- dat_monthly_stv_std_efdc %>% filter(perc_235_violation > 10)

#Calculate which months violate the geometric mean standard-----
dat_monthly_geomean_efdc <- dat %>% group_by(datetime) %>% 
  mutate(ln_total = log(downstream_boundary))
  
dat_monthly_geomean_efdc <- dat_monthly_geomean_efdc %>% group_by(year_month) %>% 
  dplyr::summarise(total = exp(mean(ln_total)))

dat_geomean_check <- dat_monthly_geomean_efdc %>% filter(total > 126)

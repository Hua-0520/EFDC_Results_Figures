



dat <- gather(dat_efdc, key = station, value = result, 2:9)
# dat <- dat %>% filter(station %in% station_nm_of_int)
dat$station <- as.factor(dat$station)
dat$year_fac <- year(dat$datetime) %>% as.factor(.)

yrs <- unique(dat$year_fac)

dat <- dat %>% filter(station %in% station_nm_of_int) %>% 
  droplevels()



dat$station <- fct_relevel(dat$station, as.character(station_nm_of_int))

for (i in 1:length(yrs)){
  df <- dat %>% filter(year_fac == yrs[i])
  x_min <- min(df$datetime) %>% floor_date(., unit = 'day')
  x_max <- max(df$datetime)%>% ceiling_date(., unit = 'day')
  
  x <- ggplot(df, aes(x = datetime, y = result)) +
    geom_line(color = 'dodgerblue3', lwd = 1) +
    facet_wrap(~station, scales = 'fixed', ncol = 1, drop = T) +
    scale_x_datetime(expand = c(0, 0), limits = c(x_min, x_max)
                     , breaks = date_breaks("1 month")
                     , labels = date_format("%m")
                     ) +
    scale_y_log10(expand = c(0, 0)
                  , limits = c(1, 1000000)) +
    labs(x = 'Month', y = 'E. coli (CFU/100 mL)') +
    theme_bw() +
    theme(legend.title = element_blank()
          , legend.position = 'top'
          , legend.key.size = unit(0.2, 'in')) +
    theme(strip.background = element_blank()) 
}



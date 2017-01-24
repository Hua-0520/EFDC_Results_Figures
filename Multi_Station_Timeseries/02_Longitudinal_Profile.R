wd_print <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/', scenario_name, sep = '')


dat <- gather(dat_efdc, key = station, value = result, 2:9)
dat$year_fac <- year(dat$datetime) %>% as.factor(.)

yrs <- unique(dat$year_fac)

dat <- dat %>% filter(station %in% station_nm_of_int)


#Adding some factors for plotting
dat$station_fac <- fct_relevel(dat$station, as.character(station_nm_of_int))
dat_wq$station_fac <- fct_relevel(dat_wq$station, as.character(station_nm_of_int))
dat_wq$year_fac <- year(dat_wq$date_time) %>% as.factor(.)

setwd(wd_print)
for (i in 1:length(yrs)){
  df <- dat %>% filter(year_fac == yrs[i])
  df_wq <- dat_wq %>% filter(year_fac == yrs[i])
  color_yrs <- c('2011' = 'dodgerblue3', '2012' = 'dodgerblue3', '2013' = 'dodgerblue3')
  plot_name <- paste(scenario_name, '_', unique(df$year_fac), '_Time_Series_with_Data.png', sep = '')

  x_min <- min(df$datetime) %>% floor_date(., unit = 'day')
  x_max <- max(df$datetime)%>% ceiling_date(., unit = 'day')
  
  x <- ggplot(df, aes(x = datetime, y = result)) +
    geom_line(aes(color = year_fac), lwd = 1) +
    geom_point(data = df_wq
               , aes(x = date_time, y = result, shape = nd_qualifier), lwd = 3) +
    facet_wrap(~station_fac, scales = 'fixed', ncol = 1, drop = T) +
    scale_x_datetime(expand = c(0, 0), limits = c(x_min, x_max)
                     , breaks = date_breaks("1 month")
                     , labels = date_format("%m")
                     ) +
    scale_y_log10(expand = c(0, 0)
                  , limits = c(1, 1000000)) +
    scale_color_manual(values = color_yrs) +
    scale_shape_manual(values = c('D' = 16, 'ND' = 21)) +
    labs(x = 'Month', y = 'E. coli (CFU/100 mL)') +
    theme_bw() +
    theme(legend.title = element_blank()
          , legend.position = 'top'
          , legend.key.size = unit(0.2, 'in')) +
    theme(strip.background = element_blank()) 
  
  ggsave(filename = plot_name, plot = x, width = 8, height = 10, units = 'in')
}



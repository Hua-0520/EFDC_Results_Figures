#Working directories-----------------
wd_print <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/'
                  , component_scenario_name, sep = '')

#Parameters--------------------------
plot_name <- paste(component_scenario_name, '_GEOMEAN_Component_Check_Plot.png', sep = '')

#Data munging------------------------
dat <- dat_complete %>% select(1:2, 7)

dat$year_month <- with(dat_complete, paste(year(datetime), '-'
                                           , str_pad(month(datetime), width = 2, side = 'left', pad = '0')
                                           , sep = ''))
names(dat) <- normVarNames(names(dat))

#Spread and transform component data
dat_monthly <- spread(dat, component, downstream_boundary) 

#Separate out native E. coli data from component run
dat_monthly_ecoli <- dat_monthly %>% select(datetime, year_month, Ecoli)

dat_monthly <- if('Ecoli' %in% colnames(dat_monthly)){dat_monthly %>% select(-Ecoli)}
  
names(dat_monthly) <- normVarNames(names(dat_monthly))
dat_monthly$total <- rowSums(dat_monthly[ , 3:7])

#Calculate geomean and STV for component total in component run--------------------
#Calculate which months violate the STV standard
dat_monthly_stv_std_dye <- dat_monthly %>% 
  group_by(year_month) %>% 
  dplyr::summarise(ct = n(), gtr_235_ct = sum(total > 235)) %>% 
  mutate(perc_235_violation_dye = gtr_235_ct / ct * 100) %>% 
  select(year_month, perc_235_violation_dye)

#Calculate which months violate the geometric mean standard
dat_monthly_geomean_sum <- dat_monthly %>% group_by(datetime) %>% 
  mutate(ln_total = log(total))

dat_monthly_geomean_sum <- dat_monthly_geomean_sum %>% group_by(year_month) %>% 
  dplyr::summarise(total_sum = exp(mean(ln_total)))


# dat_monthly <- dat_monthly %>% group_by(datetime) %>% 
#   mutate(ln_total =log(total)
#          , ln_wwtp = log(total - wwtp)
#          , ln_unknown = log(total - unknown)
#          , ln_stormwater = log(total - stormwater)
#          , ln_csos = log(total - csos)
#          , ln_upstream = log(total - upstream))
# 
# dat_monthly <- dat_monthly %>% group_by(year_month) %>% 
#   dplyr::summarise(total = exp(mean(ln_total))
#             , wwtp = exp(mean(ln_wwtp))
#             , unknown = exp(mean(ln_unknown))
#             , stormwater = exp(mean(ln_stormwater))
#             , csos = exp(mean(ln_csos))
#             , upstream = exp(mean(ln_upstream)))
# 
# dat_year_mo <- data.frame(year_month = dat_monthly[ , 1])
# 
# #Filter for total_efdc > 126, but use the component total for the calculation
# dat_plot <- dat_monthly %>% 
#   filter(total_efdc > 126) %>% 
#   mutate(upstream = (total - upstream) / total
#          , csos = (total - csos) / total
#          , stormwater = (total - stormwater) / total
#          , unknown = (total - unknown) / total
#          , wwtp = (total - wwtp) / total)
# 
# names(dat_plot)[3] <- c('total_geomean')
# 
# dat_plot$total <- rowSums(dat_plot[ , 4:8])
# 
# dat_plot <- dat_plot %>% 
#   mutate(upstream = upstream / total * 100
#          , csos = csos / total * 100
#          , stormwater = stormwater / total * 100
#          , unknown = unknown / total * 100
#          , wwtp = wwtp / total * 100) %>% 
#   left_join(dat_year_mo, .) %>% 
#   select(year_month, upstream, csos, stormwater, unknown, wwtp, -total_geomean, -total) %>% 
#   gather(., component, perc_contribution, 2:6)

#Calculate geomean and STV for native dye state in component run--------------------
names(dat_monthly_ecoli) <- normVarNames(names(dat_monthly_ecoli))

#Calculate which months violate the STV standard
dat_monthly_stv_std_dye <- dat_monthly_ecoli %>% 
  group_by(year_month) %>% 
  dplyr::summarise(ct = n(), gtr_235_ct = sum(ecoli > 235)) %>% 
  mutate(perc_235_violation_dye = gtr_235_ct / ct * 100) %>% 
  select(year_month, perc_235_violation_dye)

#Calculate which months violate the geometric mean standard
dat_monthly_geomean_dye <- dat_monthly_ecoli %>% group_by(datetime) %>% 
  mutate(ln_total = log(ecoli))

dat_monthly_geomean_dye <- dat_monthly_geomean_dye %>% group_by(year_month) %>% 
  dplyr::summarise(total_dye = exp(mean(ln_total)))

#Plot!-------------------------------
#Exceedance plot for component total
x <- ggplot(dat_monthly_geomean_sum, aes(x = factor(year_month), y = total_sum)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 126, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 250)) +
  labs(title = 'Component Run: Sum of Components', x = '', y = 'E. coli Geometric Mean \n(CFU/100mL)') +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(plot.title = element_text(hjust=0.5)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank()) +
  theme(plot.margin=unit(c(10, 8, 0, 8), 'pt')) #TRBL

#Exceedance plot for std EFDC run
xx <- ggplot(dat_monthly_geomean_efdc, aes(x = factor(year_month), y = total_efdc)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 126, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 250)) +
  labs(title = 'Standard Run: Dye Variable', x = '', y = 'E. coli Geometric Mean \n(CFU/100mL)') +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(plot.title = element_text(hjust=0.5)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank()) +
  theme(plot.margin=unit(c(10, 8, 0, 8), 'pt')) #TRBL


#Exceedance plot for native dye variable from component run
xxx <- ggplot(dat_monthly_geomean_dye, aes(x = factor(year_month), y = total_dye)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 126, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 250)) +
  labs(title = 'Standard Run: Dye Variable',x = '', y = 'E. coli Geometric Mean \n(CFU/100mL)') +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(plot.title = element_text(hjust=0.5)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank()) +
  theme(plot.margin=unit(c(10, 8, 0, 8), 'pt')) #TRBL

plot_geomean <- grid.arrange(x, xx, xxx, ncol = 1)

setwd(wd_print)
ggsave(filename = plot_name, plot = plot_geomean, width = 6, height = 9, units = 'in')

# #Printing which months violate the std to txt------------------------------
# geomean_violations <- dat_plot %>% filter(!is.na(perc_contribution))
# geomean_violations <- unique(geomean_violations$year_month)
# 
# setwd(wd_print)
# write.table(geomean_violations, file = paste(scenario_name, '_GEOMEAN_Standard_Violations.txt', sep = '')
#             , quote = F
#             , row.names = F
#             , col.names = F)
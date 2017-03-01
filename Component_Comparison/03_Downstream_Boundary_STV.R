#Working directories-----------------
wd_print <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/'
                  , component_scenario_name, sep = '')

#Parameters--------------------------
plot_name <- paste(component_scenario_name, '_STV_Component_Check_Plot.png', sep = '')

#Data munging------------------------
dat <- dat_complete %>% select(1:2, 7)

dat$year_month <- with(dat_complete, paste(year(datetime), '-'
                               , str_pad(month(datetime), width = 2, side = 'left', pad = '0')
                               , sep = ''))
names(dat) <- normVarNames(names(dat))

#Check to see if "Ecoli" exists in the components field
if(!('Ecoli' %in% unique(dat$component))){
  dat_ecoli <- dat %>% group_by(datetime) %>% 
    dplyr::summarise(downstream_boundary = sum(downstream_boundary)) %>% 
    mutate(component = 'Ecoli')
  dat_ecoli$component <- as.factor(dat_ecoli$component)
  dat_ecoli$year_month <- with(dat_ecoli, paste(year(datetime), '-'
                                             , str_pad(month(datetime), width = 2, side = 'left', pad = '0')
                                             , sep = ''))
  dat <- rbind(dat, dat_ecoli)
}

#Calculate geomean and STV for native dye state in component run--------------------
# names(dat_monthly_ecoli) <- normVarNames(names(dat_monthly_ecoli))

#Filter for dye variable from component run
dat <- dat %>% filter(component == 'Ecoli')

#Calculate which months violate the STV standard
dat_monthly_stv_std_dye <- dat %>%
  group_by(year_month) %>%
  dplyr::summarise(ct = n(), gtr_235_ct = sum(downstream_boundary > 235)) %>%
  mutate(perc_235_violation_dye = gtr_235_ct / ct * 100) %>%
  select(year_month, perc_235_violation_dye)

#Plot!-------------------------------
#Exceedance plot
xx <- ggplot(dat_monthly_stv_std_efdc, aes(x = factor(year_month), y = perc_235_violation_efdc)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 10, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 100)) +
  labs(title = 'Standard Run: Dye Variable',x = '', y = 'Percent Exceendance \nof STV Threshold (%)') +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(plot.title = element_text(hjust=0.5)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank()) +
  theme(plot.margin=unit(c(10, 8, 0, 8), 'pt')) #TRBL

#Exceedance plot
x <- ggplot(dat_monthly_stv_std_dye, aes(x = factor(year_month), y = perc_235_violation_dye)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 10, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 100)) +
  labs(title = 'Component Run: Dye Variable',x = '', y = 'Percent Exceendance \nof STV Threshold (%)') +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(plot.title = element_text(hjust=0.5)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank()) +
  theme(plot.margin=unit(c(10, 8, 0, 8), 'pt')) #TRBL

plot_stv <- grid.arrange(xx, x, ncol = 1)

setwd(wd_print)
ggsave(filename = plot_name, plot = plot_stv, width = 6, height = 6, units = 'in')

#Printing which months violate the std to txt------------------------------
# stv_violations <- dat_plot %>% filter(!is.na(perc_contribution))
# stv_violations <- unique(stv_violations$year_month)
# 
# setwd(wd_print)
# write.table(stv_violations, file = paste(scenario_name, '_STV_Standard_Violations.txt', sep = '')
#             , quote = F
#             , row.names = F
#             , col.names = F)


#Working directories-----------------
wd_print <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/'
                  , scenario_name, sep = '')

#Parameters--------------------------
plot_name <- paste(scenario_name, '_STV_Component_Plot.png', sep = '')

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

dat_monthly_stv_std <- dat %>% 
  filter(component == 'Ecoli') %>% 
  group_by(year_month) %>% 
  dplyr::summarise(ct = n(), gtr_235_ct = sum(downstream_boundary > 235)) %>% 
  mutate(perc_235_violation = gtr_235_ct / ct * 100) %>% 
  select(year_month, perc_235_violation)

#Calculate totals for each category if the total E. coli > 235 cfu/100mL
dat_monthly <- spread(dat, component, downstream_boundary) %>% 
  select(-starts_with('Ecoli')) %>% 
  mutate(total = rowSums(.[, 3:7])) %>% 
  group_by(year_month) %>% 
  filter(total > 235) %>% 
  dplyr::summarise(total = sum(total)
                   , upstream = sum(Upstream)
                   , csos = sum(CSOs)
                   , stormwater = sum(Stormwater)
                   , unknown = sum(Unknown)
                   , wwtp = sum(WWTP)) %>% 
  left_join(dat_monthly_stv_std, .)

#Replacing component total results with EFDC results
dat_monthly <- left_join(dat_monthly, dat_monthly_stv_std_efdc)
dat_monthly <- dat_monthly %>% select(1, 9, 3:8)

#Calculate percent contribution for each category if the 
#monthly exceedance percent is is >10%
#and reshape into something useable for ggplot
dat_plot <- dat_monthly %>% 
  filter(perc_235_violation_efdc > 10) %>% 
  mutate(upstream_perc_cont = upstream / total * 100
         , csos_perc_cont = csos / total * 100
         , stormwater_perc_cont = stormwater / total * 100
         , unknown_perc_cont = unknown / total * 100
         , wwtp_perc_cont = wwtp / total * 100) %>% 
  left_join(dat_monthly, .) %>% 
  select(1, 9:13) %>% 
  gather(., key = component, value = perc_contribution, 2:6)

#Add and rename a few factor fields
dat_plot[, 4:5] <- lapply(dat_plot[, 1:2], as.factor)
names(dat_plot)[4:5] <- c('year_mo_fac', 'component_fac')

#Reorder factor levels for components
dat_plot$component_fac <- fct_relevel(dat_plot$component_fac, 'upstream_perc_cont'
                                      , 'csos_perc_cont', 'stormwater_perc_cont'
                                      , 'unknown_perc_cont', 'wwtp_perc_cont')

leg_labels <- c('Upstream', 'CSOs', 'Stormwater', 'Background', 'WWTP')
leg_colors <- c('#80B1D3', '#FB8072', '#8DD3C7', '#BEBADA', '#FFFFB3')

#Plot!-------------------------------
#Exceedance plot
x <- ggplot(dat_monthly, aes(x = factor(year_month), y = perc_235_violation_efdc)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 10, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 100)) +
  labs(x = '', y = 'Percent Exceendance \nof STV Threshold (%)') +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank()) +
  theme(plot.margin=unit(c(10, 8, 0, 8), 'pt')) #TRBL

#Percent contribution plot
xx <- ggplot(dat_plot, aes(x = year_mo_fac, y = perc_contribution, fill = component_fac)) +
  geom_bar(stat = 'identity') +
  scale_y_continuous(labels = comma, expand = c(0, 0)) +
  scale_color_manual(values = leg_colors, labels = leg_labels) +
  scale_fill_manual(values = leg_colors, labels = leg_labels) +
  labs(x = 'Year-Month', y = 'Percent Contribution \nto STV Exceedance (%)') +
  guides(fill = guide_legend(nrow = 1, reverse=F)
         , color = guide_legend(nrow = 1, reverse=F)) +
  theme_bw() +
  theme(legend.title = element_blank()
        , legend.position = 'top'
        , legend.key.size = unit(0.2, 'in')) +
  theme(strip.background = element_blank()) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank())+
  theme(plot.margin=unit(c(-8, 8, 8, 8), 'pt')) #TRBL

plot_stv <- grid.arrange(x, xx, ncol = 1)

setwd(wd_print)
ggsave(filename = plot_name, plot = plot_stv, width = 6, height = 6, units = 'in')

#Printing which months violate the std to txt------------------------------
stv_violations <- dat_plot %>% filter(!is.na(perc_contribution))
stv_violations <- unique(stv_violations$year_month)

setwd(wd_print)
write.table(stv_violations, file = paste(scenario_name, '_STV_Standard_Violations.txt', sep = '')
            , quote = F
            , row.names = F
            , col.names = F)


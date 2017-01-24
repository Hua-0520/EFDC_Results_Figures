#Working directories-----------------
wd_print <- paste('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Figures/'
                  , scenario_name, sep = '')

#Parameters--------------------------
plot_name <- paste(scenario_name, '_GEOMEAN_Component_Plot.png', sep = '')

#Data munging------------------------
dat <- dat_complete %>% select(1:2, 7)

dat$year_month <- with(dat_complete, paste(year(datetime), '-'
                                           , str_pad(month(datetime), width = 2, side = 'left', pad = '0')
                                           , sep = ''))
names(dat) <- normVarNames(names(dat))

#Spread and transform data
dat_monthly <- spread(dat, component, downstream_boundary) 

if('Ecoli' %in% colnames(dat_monthly)){dat_monthly %>% select(-Ecoli)}
  

names(dat_monthly) <- normVarNames(names(dat_monthly))
dat_monthly$total <- rowSums(dat_monthly[ , 3:7])

dat_monthly <- dat_monthly %>% group_by(datetime) %>% 
  mutate(ln_total =log(total)
         , ln_wwtp = log(total - wwtp)
         , ln_unknown = log(total - unknown)
         , ln_stormwater = log(total - stormwater)
         , ln_csos = log(total - csos)
         , ln_upstream = log(total - upstream))

dat_monthly <- dat_monthly %>% group_by(year_month) %>% 
  dplyr::summarise(total = exp(mean(ln_total))
            , wwtp = exp(mean(ln_wwtp))
            , unknown = exp(mean(ln_unknown))
            , stormwater = exp(mean(ln_stormwater))
            , csos = exp(mean(ln_csos))
            , upstream = exp(mean(ln_upstream)))

dat_year_mo <- data.frame(year_month = dat_monthly[ , 1])

# #Replacing component total results with EFDC results
dat_monthly <- left_join(dat_monthly, dat_monthly_geomean_efdc)
dat_monthly <- dat_monthly %>% select(1:2, 8, 3:7)

#Filter for total_efdc > 126, but use the component total for the calculation
dat_plot <- dat_monthly %>% 
  filter(total_efdc > 126) %>% 
  mutate(upstream = (total - upstream) / total
         , csos = (total - csos) / total
         , stormwater = (total - stormwater) / total
         , unknown = (total - unknown) / total
         , wwtp = (total - wwtp) / total)

names(dat_plot)[3] <- c('total_geomean')

dat_plot$total <- rowSums(dat_plot[ , 4:8])

dat_plot <- dat_plot %>% 
  mutate(upstream = upstream / total * 100
         , csos = csos / total * 100
         , stormwater = stormwater / total * 100
         , unknown = unknown / total * 100
         , wwtp = wwtp / total * 100) %>% 
  left_join(dat_year_mo, .) %>% 
  select(year_month, upstream, csos, stormwater, unknown, wwtp, -total_geomean, -total) %>% 
  gather(., component, perc_contribution, 2:6)

#Add and rename a few factor fields
dat_plot[, 4:5] <- lapply(dat_plot[, 1:2], as.factor)
names(dat_plot)[4:5] <- c('year_mo_fac', 'component_fac')

#Reorder factor levels for components
dat_plot$component_fac <- fct_relevel(dat_plot$component_fac, 'upstream'
                                      , 'csos', 'stormwater'
                                      , 'unknown', 'wwtp')

leg_labels <- c('Upstream', 'CSOs', 'Stormwater', 'Background', 'WWTP')
leg_colors <- c('#80B1D3', '#FB8072', '#8DD3C7', '#BEBADA', '#FFFFB3')

#Plot!-------------------------------
#Exceedance plot
x <- ggplot(dat_monthly, aes(x = factor(year_month), y = total_efdc)) +
  geom_bar(stat = 'identity', fill = 'black') +
  geom_hline(yintercept = 126, color = 'red') +
  scale_y_continuous(labels = comma, expand = c(0, 0), limits = c(0, 250)) +
  labs(x = '', y = 'E. coli Geometric Mean \n(CFU/100mL)') +
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
  labs(x = 'Year-Month', y = 'Percent Contribution \nto Geometric Mean') +
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

plot_geomean <- grid.arrange(x, xx, ncol = 1)

setwd(wd_print)
ggsave(filename = plot_name, plot = plot_geomean, width = 6, height = 6, units = 'in')

#Printing which months violate the std to txt------------------------------
geomean_violations <- dat_plot %>% filter(!is.na(perc_contribution))
geomean_violations <- unique(geomean_violations$year_month)

setwd(wd_print)
write.table(geomean_violations, file = paste(scenario_name, '_GEOMEAN_Standard_Violations.txt', sep = '')
            , quote = F
            , row.names = F
            , col.names = F)
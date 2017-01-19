#Additional required libraries-------
library(plyr)
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(stringr)
library(rattle)
library(scales)

#Working directories-----------------
wd_data_src <- c('W:/RICHCWA/WinModel/EFDC/R_Scripts/EFDC_Results_Figures/Component_Analysis')

#Load data---------------------------
setwd(wd_data_src)
# source('00_Read_Component_Data_xlsb_Format.R')

#Temporary storage of data for faster loading
##Maybe move this to the Read_Component file?
setwd('W:/RICHCWA/WinModel/EFDC/RVAJR_Components/RVAJR_C01')
dat_complete <- readRDS('RVAJR_C01_test_data.rds')

dat <- dat_complete %>% select(1:2, 7)

dat$year_month <- with(dat_complete, paste(year(datetime), '-'
                               , str_pad(month(datetime), width = 2, side = 'left', pad = '0')
                               , sep = ''))

names(dat) <- normVarNames(names(dat))

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

#Calculate percent contribution for each category if the 
#monthly exceedance percent is is >10%
#and reshape into something useable for ggplot
dat_plot <- dat_monthly %>% 
  filter(perc_235_violation > 10) %>% 
  mutate(upstream_perc_cont = upstream / total * 100
         , csos_perc_cont = csos / total * 100
         , stormwater_perc_cont = stormwater / total
         , unknown_perc_cont = unknown / total
         , wwtp_perc_cont = wwtp / total) %>% 
  left_join(dat_monthly, .) %>% 
  select(1, 9:13) %>% 
  gather(., key = component, value = perc_contribution, 2:6)

#Add and rename a few factor fields
dat_plot[, 4:5] <- lapply(dat_plot[, 1:2], as.factor)
names(dat_plot)[4:5] <- c('year_mo_fac', 'component_fac')

#Plot!
x <- ggplot(dat_plot, aes(x = year_mo_fac, y = perc_contribution, fill = component_fac)) +
  geom_bar(stat = 'identity') +
  scale_y_continuous(labels = comma, expand = c(0, 0)) +
  scale_color_brewer(palette = 'Set3') +
  scale_fill_brewer(palette = 'Set3') +
  labs(x = 'Year-Month', y = 'Percent Contribution to STV Exceedance (%)') +
  guides(fill = guide_legend(nrow = 1, reverse=F)
         , color = guide_legend(nrow = 1, reverse=F)) +
  theme_bw() +
  # expand_limits(y = c(0, 0)) +
  theme(legend.title = element_blank()
        , legend.position = 'top'
        , legend.key.size = unit(0.2, 'in')) +
  theme(strip.background = element_blank()) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, vjust = 0.5)) +
  theme(panel.grid = element_blank())


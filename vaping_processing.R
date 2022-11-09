dat <- read.csv("vaping-ban-panel.csv")

library(tidyverse)

dat_treatment <- dat %>% 
  filter(Year == 2021) %>%
  mutate(treatment = ifelse(Vaping_Ban == 1, 1, 0)) %>%
  select(State_Id, treatment) %>%
  full_join(., dat)

write.csv(dat_treatment, "vaping-ban-panel.csv")
uniqueTypes <- pad %>% 
  distinct(lhnd, hhnd) %>% 
  mutate(lhnd=str_trim(lhnd), hhnd=str_trim(hhnd)) %>% 
  separate(lhnd, c('lhnd_l', 'lhnd_r'), sep="-") %>% 
  separate(hhnd, c('hhnd_l', 'hhnd_r'), sep="-") %>% 
  separate(lhnd_r, c('lhnd_r', 'lhnd_r_special', 'lhnd_r_special_2'), sep=" ") %>% 
  separate(hhnd_r, c('hhnd_r', 'hhnd_r_special', 'hhnd_r_special_2'), sep=" ") %>% 
  separate(lhnd_l, c('lhnd_l', 'lhnd_l_special', 'lhnd_l_special_2'), sep=" ") %>% 
  separate(hhnd_l, c('hhnd_l', 'hhnd_l_special', 'hhnd_l_special_2'), sep=" ") %>% 
  mutate(lhnd_l = str_replace(lhnd_l, '[0-9]+', 'n') %>% str_replace_all('[A-Z]', 'L')) %>%
  mutate(lhnd_r = str_replace(lhnd_r, '[0-9]+', 'n') %>% str_replace_all('[A-Z]', 'L')) %>%
  mutate(hhnd_l = str_replace(hhnd_l, '[0-9]+', 'n') %>% str_replace_all('[A-Z]', 'L')) %>%
  mutate(hhnd_r = str_replace(hhnd_r, '[0-9]+', 'n') %>% str_replace_all('[A-Z]', 'L')) %>%
  select(lhnd_l, lhnd_r, hhnd_l, hhnd_r) %>%
  distinct

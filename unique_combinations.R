uniqueTypes <- pad %>% 
  distinct(lhnd, hhnd) %>% 
  mutate(lhnd=str_trim(lhnd), hhnd=str_trim(hhnd)) %>% 
  separate(lhnd, c('lhnd_l', 'lhnd_r'), sep="-") %>% 
  separate(hhnd, c('hhnd_l', 'hhnd_r'), sep="-") %>%
  separate(lhnd_r, c('lhnd_r', 'lhnd_r_special', 'lhnd_r_special_2'), sep=" ") %>%
  separate(hhnd_r, c('hhnd_r', 'hhnd_r_special', 'hhnd_r_special_2'), sep=" ") %>%
  separate(lhnd_l, c('lhnd_l', 'lhnd_l_special', 'lhnd_l_special_2'), sep=" ") %>%
  separate(hhnd_l, c('hhnd_l', 'hhnd_l_special', 'hhnd_l_special_2'), sep=" ") %>%
  extract(lhnd_l, into=c('lhnd_l_num', 'lhnd_l_letter'), '([:digit:]+)([:alpha:]+)?') %>%
  mutate(lhnd_l_num_parsed = as.integer(lhnd_l_num)) %>%
  extract(lhnd_r, into=c('lhnd_r_num', 'lhnd_r_letter'), '([:digit:]+)([:alpha:]+)?') %>%
  mutate(lhnd_r_num_parsed = as.integer(lhnd_r_num)) %>%
  extract(hhnd_l, into=c('hhnd_l_num', 'hhnd_l_letter'), '([:digit:]+)([:alpha:]+)?') %>%
  mutate(hhnd_l_num_parsed = as.integer(hhnd_l_num)) %>%
  extract(hhnd_r, into=c('hhnd_r_num', 'hhnd_r_letter'), '([:digit:]+)([:alpha:]+)?') %>% 
  mutate(hhnd_r_num_parsed = as.integer(hhnd_r_num))

uniqueTypes %>% View

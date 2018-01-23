pad %>%
  separate(lhns, c('lhns_dash', 'lhns_ldash', 'lhns_rdash', 'lhns_suffix'), sep=c(1,6,9)) %>%
  separate(hhns, c('hhns_dash', 'hhns_ldash', 'hhns_rdash', 'hhns_suffix'), sep=c(1,6,9)) %>%
  View

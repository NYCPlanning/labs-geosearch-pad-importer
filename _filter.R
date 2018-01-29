"FILTERING ROWS" %>% print
# W, F, B adresses types are filtered out because they are not useful in a geocoder
# remove white space in street name column

pad <- pad %>%
  filter(addrtype != 'W' & addrtype != 'F' & addrtype != 'B')

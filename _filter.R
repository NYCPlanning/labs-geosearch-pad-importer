"FILTERING ROWS" %>% print
# W, F, B adresses types are filtered out because they are not useful in a geocoder
# remove white space in street name column
# There are only 4 Distinct fields in the naubflag column ('NA', 'W', 'B', 'F').
# We only need NA because we have to filter out 'W', 'B', 'F' from naubflag column. 

pad <- pad %>%
  filter(is.na(naubflag))

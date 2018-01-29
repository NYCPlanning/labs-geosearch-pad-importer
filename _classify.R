"CLASSIFYING ROWS" %>% print
# This step assigns a rowType to each row by creating a new column called rowType, checking some
# conditions, and seting the value for that row's rowType as one of the several types. These types
# determine how the row is interpolated (or not), and sequenced, so it can be expanded into new rows.
# Finally, this will filter out any rows that don't get assigned a rowType. 
pad <- pad %>%
  mutate(
    rowType = case_when(
      lhns == hhns                                                                            ~ 'singleAddress',
      addrtype == 'G' | addrtype == 'N' | addrtype == 'X'                                     ~ 'nonAddressable',
      lhns_hyphen == FALSE & is.na(lhns_suffix) & is.na(hhns_suffix)                          ~ 'numericType',
      lhns_hyphen == TRUE & lhnd != hhnd & is.na(lhns_suffix) & is.na(hhns_suffix)            ~ 'hyphenNoSuffix',
      lhns_hyphen == FALSE & lhns_suffix %in% LETTERS                                         ~ 'noHyphenSuffix',
      lhns_hyphen == TRUE & lhns_suffix %in% LETTERS  &
        lhns_hyphen == TRUE & hhns_suffix %in% LETTERS                                        ~ 'hyphenSuffix'
    )
  ) %>%
  filter(!is.na(rowType))

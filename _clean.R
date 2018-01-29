"CLEANING DATA" %>% print
# clear whitespace from alternate streetnames
snd <- snd %>%
  mutate(alt_st_name = str_trim(gsub("\\s+", " ", alt_st_name))) %>%
  mutate(full_stname = str_trim(gsub("\\s+", " ", full_stname)))

# Left join BBL bill data; unite boro, block, lots, for a concatenated join keys
pad <- padRaw %>%
  left_join(bbl, by = c('boro', 'block', 'lot')) %>%
  unite(billbbl, billboro, billblock, billlot, sep="", remove=FALSE) %>%
  unite(bbl, boro, block, lot, sep="", remove=FALSE) %>%
  mutate(
    bbl = case_when(
      (lot >= 1001 & lot <= 6999) ~ billbbl,
      TRUE                        ~ bbl
    )
  )

# Split the house number sort columns into discrete columns with separator being the specific format position of the PAD data.
# Also, create new columns that are numeric or character-parsed versions of the columns for later use.
pad <- pad %>%
  separate(lhns, c('lhns_hyphen', 'lhns_lhyphen', 'lhns_rhyphen', 'lhns_suffix'), sep=c(1,6,9), remove=FALSE) %>%
  separate(hhns, c('hhns_hyphen', 'hhns_lhyphen', 'hhns_rhyphen', 'hhns_suffix'), sep=c(1,6,9), remove=FALSE) %>%
  mutate(lhns_hyphen = parse_logical(lhns_hyphen)) %>%
  mutate(hhns_hyphen = parse_logical(hhns_hyphen)) %>%
  left_join(suffix_lookup, by=c('lhns_suffix' = 'code')) %>%
  mutate(lhns_suffix = suffix) %>%
  left_join(suffix_lookup, by=c('hhns_suffix' = 'code'), suffix=c('l','h')) %>%
  mutate(
    hhns_suffix = case_when(
      is.na(suffixh) ~ suffixl,
      TRUE           ~ suffixh
    )
  ) %>%
  mutate(
    lhns_rhyphen = case_when(
      (lhns_hyphen == TRUE) ~ lhns_rhyphen
    )
  ) %>%
  mutate(
    hhns_rhyphen = case_when(
      (hhns_hyphen == TRUE) ~ hhns_rhyphen
    )
  ) %>%
  mutate(lhns_lhyphen_i = parse_integer(lhns_lhyphen)) %>%
  mutate(lhns_rhyphen_i = parse_integer(lhns_rhyphen)) %>%
  mutate(hhns_lhyphen_i = parse_integer(hhns_lhyphen)) %>%
  mutate(hhns_rhyphen_i = parse_integer(hhns_rhyphen)) %>%
  mutate(
    lhns_numeric = parse_integer(str_replace_all(lhnd, '\\D+', '')),
    lhns_lhyphen_i = parse_integer(lhns_lhyphen_i),
    lhns_rhyphen_i = parse_integer(lhns_rhyphen_i)
  ) %>%
  mutate(
    hhns_numeric = parse_integer(str_replace_all(hhnd, '\\D+', '')),
    hhns_lhyphen_i = parse_integer(hhns_lhyphen_i),
    hhns_rhyphen_i = parse_integer(hhns_rhyphen_i)
  )

# join on bin(pluto) and bbl(building footprint) lookups to get lat and lng,
# if bin lookup does not get a a lat/lng, use the bbl lookup values, else NA
pad <- pad %>%
  left_join(bincentroids, by = 'bin') %>%
  left_join(bblcentroids, by = 'bbl') %>%
  mutate(
    lat = case_when(
      is.na(lat.x) & is.na(lng.x)   ~ lat.y,
      TRUE                          ~ lat.x
    ),
    lng = case_when(
      is.na(lat.x) & is.na(lng.x)   ~ lng.y,
      TRUE                          ~ lng.x
    )
  )

# Replace NAs values for `addrtype` and `validlgcs` columns because
# they must be character-type values to be used in other functions.
# NA address types are asssigned as "OTHER"
# validlgcs is assigned blank string for string substitution 
pad <- pad %>%
  replace_na(list(addrtype = 'OTHER', validlgcs = ''))

# trim street name field, remove multiple spaces
pad <- pad %>% 
  mutate(stname = str_trim(gsub("\\s+", " ", stname)))

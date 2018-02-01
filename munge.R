source('_dependencies.R')
source('_download_data.R')
source('_functions.R')
source('_load_data.R')
source('_clean.R')
source('_filter.R')
source('_classify.R')
source('_sequence.R')

"CHECKING EXPANSION COLUMN FOR NON-NULL/NON-NA TYPES: " %>% print
# For debugging, check if there were any rows that were missed in the iteration. 
pad %>% distinct(typeof(houseNums)) %>% print

"EXPANDING" %>% print
# This step unnests the data frame into the expanded form. It first creates a new column
# that splits the comma-separated string into an R-native list that is used for unnest. 
# It then does any other unnests.
# Two unnests are performed here: first, the interpolations, then an unnest for the LGC join keys
# After the latter joinkey is created, it performs an inner_join.
expanded <- pad %>% 
  mutate(houseNum = strsplit(houseNums, ',')) %>%
  unnest(houseNum) %>% 
  mutate(lgc = strsplit(gsub("(.{2})", "\\1,", validlgcs), ',')) %>% 
  unnest(lgc) %>%
  inner_join(snd, by=c('boro', 'sc5', 'lgc'))

# Debugging messages about type distribution
pad %>% group_by(rowType) %>% summarise(count = length(rowType)) %>% print
expanded %>% group_by(rowType) %>% summarise(count = length(rowType)) %>% print

"SELECTING RELEVANT COLUMNS FOR EXPORT" %>% print
# Simply selects only needed columns in the output.
expanded <- expanded %>%
  select(pad_bbl = bbl, houseNum, pad_bin = bin, pad_orig_stname = stname, pad_low = lhnd, pad_high = hhnd, stname = alt_st_name, zipcode, lng, lat) %>%
  filter(!is.na(lat) & !is.na(lng))

# Checks:
# 1. theoretical unnest count matches actual row count
# 2. check for NAs in crucial columns (stname, lat, lng, bbl)
"RUNNING CHECKS" %>% print
checks <- list(
  missing_lats = expanded %>% filter(is.na(lat)) %>% nrow,
  missing_lngs = expanded %>% filter(is.na(lng)) %>% nrow,
  missing_bbls = expanded %>% filter(is.na(pad_bbl)) %>% nrow,
  missing_stnames = expanded %>% filter(is.na(stname)) %>% nrow,
  missing_zips = expanded %>% filter(is.na(zipcode)) %>% nrow,
  total_rows = expanded %>% nrow,
  distinct_rows = expanded %>% distinct %>% nrow
)

checks$missing_lats %>% ifelse(., paste("✗ WARNING!", ., "MISSING LATITUDES"), "✓ LATITUDES") %>% print
checks$missing_lngs %>% ifelse(., paste("✗ WARNING!", ., "MISSING LONGITUDES"), "✓ LONGITUDES") %>% print
checks$missing_bbls %>% ifelse(., paste("✗ WARNING!", ., "MISSING BBLS"), "✓ BBLS") %>% print
checks$missing_stnames %>% ifelse(., paste("✗ WARNING!", ., "MISSING STNAMES"), "✓ STNAMES") %>% print
checks$missing_zips %>% ifelse(., paste("✗ WARNING!", ., "MISSING ZIPCODES"), "✓ ZIPCODES") %>% print
checks$total_rows %>% paste("TOTAL ROWS:", .) %>% print
checks$distinct_rows %>% paste("DISTINCT ROWS:",.) %>% print

"WRITING" %>% print
write_csv(expanded, 'data/labs-geosearch-pad-normalized.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv', na="")
file.rename('data/labs-geosearch-pad-checks-latest.json', paste(c('data/labs-geosearch-pad-checks-',print(as.integer(Sys.time())*1000, digits=15), '.json'), collapse=""))
write(toJSON(checks), 'data/labs-geosearch-pad-checks-latest.json')

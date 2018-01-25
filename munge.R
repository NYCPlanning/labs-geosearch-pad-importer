library(downloader)
library(tidyverse)

source('_functions.R')

source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"
bblcentroids <- "https://planninglabs.carto.com/api/v2/sql?q=SELECT%20bbl,%20Round(ST_X(ST_Centroid(the_geom))::numeric,5)%20AS%20lng,%20Round(ST_Y(ST_Centroid(the_geom))::numeric,5)%20AS%20lat%20FROM%20support_mappluto&format=csv"
bincentroids <- "https://planninglabs.carto.com/api/v2/sql?q=SELECT%20bin%3A%3Atext%2C%20Round%28ST_X%28ST_Centroid%28the_geom%29%29%3A%3Anumeric%2C5%29%20AS%20lng%2C%20Round%28ST_Y%28ST_Centroid%28the_geom%29%29%3A%3Anumeric%2C5%29%20AS%20lat%20FROM%20planninglabs.building_footprints&format=csv"

download(source, dest="data/dataset.zip", mode="wb") 
download(bblcentroids, dest="data/bblcentroids.csv", mode="wb")
download(bincentroids, dest="data/bincentroids.csv", mode="wb")

unzip("data/dataset.zip", exdir = "./data")

"LOADING DATA" %>% print
# Read PAD
padRaw <- read_csv('data/bobaadr.txt',
 col_types = cols(
   bin = col_character()
 ))

# Read BBL data for condos to improve BBL key later
bbl <- read_csv('data/bobabbl.txt') %>%
  select(boro, block, lot, billboro, billblock, billlot)

# Read Street Names Database to join in alternates 
snd <- read_fwf(
  'data/snd17Dcow.txt', 
  fwf_widths(
    c(1, 1, 32, 1, 1, 1, 5, 2, 3, 2, 1, 1, 2, 32, 2, 20, 1, 92),
    col_names = c('rectype', 'boro', 'stname', 'primary_flag', 'principal_flag', 'boro2', 'sc5', 'lgc', 'spv', 'filler2', 'numeric_ind', 'GFT', 'len_full_name', 'full_stname', 'min_SNL', 'stn20', 'ht_name_type_code', 'filler')
  ),
  skip = 1) %>%
  select(boro, sc5, lgc, alt_st_name = stname, full_stname, primary_flag, principal_flag)

# Read BBL centroids data, make them distinct on the BBL key
bblcentroids <- read_csv(
    'data/bblcentroids.csv',
    col_types = cols(
      bbl = col_character()
    )
  )  %>%
  distinct(bbl, .keep_all=TRUE)

# Read BIN centroids data, make them distinct on the BIN key
bincentroids <- read_csv(
    'data/bincentroids.csv',
    col_types = cols(
      bin = col_character()
    )
  ) %>%
  distinct(bin, .keep_all=TRUE) %>%
  filter(!grepl('^[1-5]0{6}$', bin))

# Read suffix lookup table to join on position-separated suffix code
suffix_lookup <- read_csv(
  'suffix_lookup.csv'
)

"CLEANING DATA" %>% print
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
      is.na(lat.x) & is.na(lat.y)   ~ lat.y,
      TRUE                          ~ lat.x
    ),
    lng = case_when(
      is.na(lat.x) & is.na(lat.y)   ~ lng.y,
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


"FILTERING ROWS" %>% print
# W, F, B adresses types are filtered out because they are not useful in a geocoder
# remove white space in street name column

pad <- pad %>%
  filter(addrtype != 'W' & addrtype != 'F' & addrtype != 'B')

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

"SEQUENCING" %>% print
# This step creates a new column, `houseNums`, which is either NA or a comma-separated list of value(s). 
# Based on the rowType above, it will delegate a particular row in the iteration to a specific function
# that constructs the comma-sparated list. This list is not a true R list, but a simple character with commas and values. 
pad <- pad %>%
  mutate(
    houseNums = apply(
      pad,
      1,
      function(x) {
        if (x['rowType'] == 'nonAddressable') {
          return(NA)
        }

        if (x['rowType'] == 'singleAddress') {
          # if no hyphen, return lhnd, else return both lhnd and lhnd with the hyphen removed
          if (grepl('-', x['lhnd'])) {
            noHyphenlhnd <- gsub("-", "", x['lhnd'])
            return(paste(x['lhnd'], noHyphenlhnd, sep=','))
          }
          return(x['lhnd'])
        }

        if (x['rowType'] == 'numericType') {
          return(numericType(x['lhns_lhyphen_i'], x['hhns_lhyphen_i']))
        }

        if (x['rowType'] == 'hyphenNoSuffix') {
          return(
            hyphenNoSuffix(
              x['lhns_numeric'],
              x['hhns_numeric'],
              x['lhns_lhyphen_i'],
              x['lhns_rhyphen_i']
            )
          )
        }

        if (x['rowType'] == 'hyphenSuffix') {
          return(
            hyphenSuffix(
              x['lhns_numeric'],
              x['hhns_numeric'],
              x['lhns_suffix'],
              x['hhns_suffix'],
              x['lhns_lhyphen_i']
            )
          )
        }
        
        if(x['rowType'] == 'noHyphenSuffix') {
          return(
            noHyphenSuffix(
              x['lhns_numeric'],
              x['hhns_numeric'],
              x['lhns_suffix'],
              x['hhns_suffix']
            )
          )
        }
        
        return(NA)
      }
    )
  )

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
expanded %>% filter(is.na(lat)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING LATITUDES"), "✓ LATITUDES") %>% print
expanded %>% filter(is.na(lng)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING LONGITUDES"), "✓ LONGITUDES") %>% print
expanded %>% filter(is.na(pad_bbl)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING BBLS"), "✓ BBLS") %>% print
expanded %>% filter(is.na(stname)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING STNAMES"), "✓ STNAMES") %>% print
expanded %>% filter(is.na(zipcode)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING ZIPCODES"), "✓ ZIPCODES") %>% print
expanded %>% nrow %>% paste("TOTAL ROWS:", .) %>% print
expanded %>% distinct %>% nrow %>% paste("DISTINCT ROWS:",.) %>% print

"WRITING" %>% print
write_csv(expanded, 'data/labs-geosearch-pad-normalized.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv', na="")

library(downloader)
library(tidyverse)

source('_functions.R')

source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"
centroids <- "https://planninglabs.carto.com/api/v2/sql?q=SELECT%20bbl,%20Round(ST_X(ST_Centroid(the_geom))::numeric,5)%20AS%20lng,%20Round(ST_Y(ST_Centroid(the_geom))::numeric,5)%20AS%20lat%20FROM%20support_mappluto&format=csv&filename=mappluto_centroids"

download(source, dest="data/dataset.zip", mode="wb") 
download(centroids, dest="data/centroids.csv", mode="wb")
unzip("data/dataset.zip", exdir = "./data")

"LOADING DATA" %>% print
padRaw <- read_csv('data/bobaadr.txt')

bbl <- read_csv('data/bobabbl.txt') %>%
  select(boro, block, lot, billboro, billblock, billlot)

snd <- read_fwf(
  'data/snd17Dcow.txt', 
  fwf_widths(
    c(1, 1, 32, 1, 1, 1, 5, 2, 3, 2, 1, 1, 2, 32, 2, 20, 1, 92),
    col_names = c('rectype', 'boro', 'stname', 'primary_flag', 'principal_flag', 'boro2', 'sc5', 'lgc', 'spv', 'filler2', 'numeric_ind', 'GFT', 'len_full_name', 'full_stname', 'min_SNL', 'stn20', 'ht_name_type_code', 'filler')
  ),
  skip = 1) %>%
  select(boro, sc5, lgc, alt_st_name = stname, full_stname, primary_flag, principal_flag)

centroids <- read_csv(
  'data/centroids.csv',
  col_types = cols(
    bbl = col_character()
  )
)

suffix_lookup <- read_csv(
  'suffix_lookup.csv'
)

"CLEANING DATA" %>% print
pad <- padRaw %>%
  left_join(bbl, by = c('boro', 'block', 'lot'))

pad <- pad %>%
  unite(billbbl, billboro, billblock, billlot, sep="", remove=FALSE)

pad <- pad %>%
  unite(bbl, boro, block, lot, sep="", remove=FALSE)

pad <- pad %>%
  separate(lhns, c('lhns_dash', 'lhns_ldash', 'lhns_rdash', 'lhns_suffix'), sep=c(1,6,9), remove=FALSE, convert=TRUE) %>%
  separate(hhns, c('hhns_dash', 'hhns_ldash', 'hhns_rdash', 'hhns_suffix'), sep=c(1,6,9), remove=FALSE, convert=TRUE) %>%
  mutate(lhns_dash = parse_logical(lhns_dash)) %>%
  mutate(hhns_dash = parse_logical(hhns_dash)) %>%
  left_join(suffix_lookup, by=c('lhns_suffix' = 'code')) %>%
  mutate(lhns_suffix = suffix) %>%
  left_join(suffix_lookup, by=c('hhns_suffix' = 'code'), suffix=c('l','h')) %>%
  mutate(hhns_suffix = suffixh)

pad <- pad %>%
  mutate(
    lhns_rdash = case_when(
      (lhns_dash == TRUE) ~ lhns_rdash
    )
  )

pad <- pad %>%
  mutate(
    hhns_rdash = case_when(
      (hhns_dash == TRUE) ~ hhns_rdash
    )
  )

pad <- pad %>%
  mutate(lhns_ldash_i = parse_integer(lhns_ldash)) %>%
  mutate(lhns_rdash_i = parse_integer(lhns_rdash)) %>%
  mutate(hhns_ldash_i = parse_integer(hhns_ldash)) %>%
  mutate(hhns_rdash_i = parse_integer(hhns_rdash))

pad <- pad %>%
  unite('lhns_numeric', c('lhns_ldash_i', 'lhns_rdash_i'), sep="", remove=FALSE) %>%
  mutate(
    lhns_numeric = parse_integer(lhns_numeric),
    lhns_ldash_i = parse_integer(lhns_ldash_i),
    lhns_rdash_i = parse_integer(lhns_rdash_i)
  )

pad <- pad %>%
  unite('hhns_numeric', c('hhns_ldash_i', 'hhns_rdash_i'), sep="", remove=FALSE) %>%
  mutate(
    hhns_numeric = parse_integer(hhns_numeric),
    hhns_ldash_i = parse_integer(hhns_ldash_i),
    hhns_rdash_i = parse_integer(hhns_rdash_i)
  )

pad <- pad %>%
  mutate(
    bbl = case_when(
      (lot >= 1001 & lot <= 6999) ~ billbbl,
      TRUE                        ~ bbl
    )
  )

pad <- pad %>%
  left_join(centroids, by = 'bbl')

pad <- pad %>%
  replace_na(list(addrtype = 'OTHER', validlgcs = ''))

"FILTER W, F, B addrtypes" %>% print
pad <- pad %>%
  filter(addrtype != 'W' & addrtype != 'F' & addrtype != 'B')

"CLASSIFYING ROWS" %>% print
pad <- pad %>%
  mutate(
    rowType = case_when(
      lhns == hhns                                                                          ~ 'singleAddress',
      addrtype == 'G' | addrtype == 'N' | addrtype == 'X'                                   ~ 'nonAddressable',
      lhns_dash == FALSE & is.na(lhns_suffix) & is.na(hhns_suffix)                          ~ 'numericType',
      lhns_dash == TRUE & lhnd != hhnd & is.na(lhns_suffix)                                 ~ 'hyphenNoSuffix',
      lhns_dash == FALSE & lhns_suffix %in% LETTERS                                         ~ 'noHyphenSuffix',
      lhns_dash == TRUE & lhns_suffix %in% LETTERS  &
        lhns_dash == TRUE & hhns_suffix %in% LETTERS                                        ~ 'hyphenSuffix'
    )
  )

pad <- pad %>%
  filter(!is.na(rowType))

"SEQUENCING" %>% print
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
          return(singleAddress(x['lhnd']))
        }

        if (x['rowType'] == 'numericType') {
          return(numericType(x['lhns_ldash_i'], x['hhns_ldash_i']))
        }

        if (x['rowType'] == 'hyphenNoSuffix') {
          return(
            hyphenNoSuffix(
              x['lhns_numeric'],
              x['hhns_numeric'],
              x['lhns_ldash_i'],
              x['lhns_rdash_i']
            )
          )
        }

        if (x['rowType'] == 'hyphenSuffix') {
          return(hyphenSuffix(x['lhnd'], x['hhnd']))
        }

        return(NA)
      }
    )
  )

"EXPANDING" %>% print
expanded <- pad %>% 
  mutate(houseNum = strsplit(houseNums, ',')) %>%
  unnest(houseNum) %>% 
  mutate(lgc = strsplit(gsub("(.{2})", "\\1,", validlgcs), ',')) %>% 
  unnest(lgc) %>%
  inner_join(snd, by=c('boro', 'sc5', 'lgc'))

# Type Distribution
pad %>% group_by(rowType) %>% summarise(count = length(rowType)) %>% print
expanded %>% group_by(rowType) %>% summarise(count = length(rowType)) %>% print

expanded <- expanded %>%
  select(bbl, houseNum, stname = alt_st_name, zipcode, lng, lat)

# Checks:
# 1. theoretical unnest count matches actual row count
# 2. check for NAs in crucial columns (stname, lat, lng, bbl)
"RUNNING CHECKS" %>% print
expanded %>% filter(is.na(lat)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING LATITUDES"), "✓ LATITUDES") %>% print
expanded %>% filter(is.na(lng)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING LONGITUDES"), "✓ LONGITUDES") %>% print
expanded %>% filter(is.na(bbl)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING BBLS"), "✓ BBLS") %>% print
expanded %>% filter(is.na(stname)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING STNAMES"), "✓ STNAMES") %>% print
expanded %>% filter(is.na(zipcode)) %>% nrow %>% ifelse(., paste("✗ WARNING!", ., "MISSING ZIPCODES"), "✓ ZIPCODES") %>% print
expanded %>% nrow %>% paste("TOTAL ROWS:", .) %>% print
expanded %>% distinct %>% nrow %>% paste("DISTINCT ROWS:",.) %>% print

"WRITING" %>% print
write_csv(expanded, 'data/labs-geosearch-pad-normalized.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv', na="")

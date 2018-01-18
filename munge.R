library(downloader)
library(tidyverse)

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

"CLEANING DATA" %>% print
pad <- padRaw %>%
  left_join(bbl, by = c('boro', 'block', 'lot'))

pad <- pad %>%
  unite(billbbl, billboro, billblock, billlot, sep="", remove=FALSE)

pad <- pad %>%
  unite(bbl, boro, block, lot, sep="", remove=FALSE)

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
      grepl("^0", lhns) & grepl("^0", hhns) & grepl("000AA$", lhns) & grepl("000AA$", hhns) ~ 'numericType',
      str_sub(lhns, 1, 1) == "1" & lhnd != hhnd & str_sub(lhns, 10, 11) == "AA"             ~ 'hyphenNoSuffix'
      # as.numeric(str_sub(lhns, 7, 9)) > 0 & str_sub(lhns, 10, 11) == "AA" & !is.na(lhns)  ~ 'nonNumericDashSepNoSuffix'
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
          return(x['lhnd'])
        }
        
        if (x['rowType'] == 'numericType') {
          paste(seq(x['lhnd'], x['hhnd'], 2), collapse=',')
        }
        
        if (x['rowType'] == 'hyphenNoSuffix'){
          
        }
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

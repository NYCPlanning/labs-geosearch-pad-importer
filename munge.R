library(downloader)
library(tidyverse)

source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"
centroids <- "https://planninglabs.carto.com/api/v2/sql?q=SELECT%20bbl,%20Round(ST_X(ST_Centroid(the_geom))::numeric,5)%20AS%20lng,%20Round(ST_Y(ST_Centroid(the_geom))::numeric,5)%20AS%20lat%20FROM%20support_mappluto&format=csv&filename=mappluto_centroids"

download(source, dest="data/dataset.zip", mode="wb") 
download(centroids, dest="data/centroids.csv", mode="wb")
unzip("data/dataset.zip", exdir = "./data")

"LOADING DATA" %>% print
pad <- read_csv('data/bobaadr.txt')
bbl <- read_csv('data/bobabbl.txt')
centroids <- read_csv(
  'data/centroids.csv',
  col_types = cols(
    bbl = col_character()
  )
)

"CLEANING DATA" %>% print
pad <- pad %>%
  left_join(bbl, by = c('boro', 'block', 'lot'))

pad <- pad %>%
  unite(billbbl, billboro, billblock, billlot, sep="", remove=FALSE)

pad <- pad %>%
  unite(bbl, boro, block, lot, sep="", remove=FALSE)

pad <- pad %>%
  mutate(
    bbl = case_when(
      (lot >= 1001 & lot <= 6999) | (lot >= 7501 & lot <= 7599) ~ billbbl,
      TRUE                                                      ~ bbl
    )
  )

pad <- pad %>%
  left_join(centroids, by = 'bbl')

"CLASSIFYING ROWS" %>% print
pad <- pad %>%
  mutate(
    rowType = case_when(
      lhns == hhns                                                                          ~ 'singleAddress',
      addrtype == 'G' | addrtype == 'N' | addrtype == 'X'                                   ~ 'nonAddressable',
      grepl("^0", lhns) & grepl("^0", hhns) & grepl("000AA$", lhns) & grepl("000AA$", hhns) ~ 'numericType'
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
        
        if (x['rowType'] == 'numericType') {
          paste(seq(x['lhnd'], x['hhnd'], 2), collapse=',')
        }
      }
    )
  )

"EXPANDING" %>% print
expanded <- pad %>% 
  mutate(houseNum = strsplit(houseNums, ',')) %>%
  unnest(houseNum)

expanded <- expanded %>%
  select(bbl, houseNum, stname, zipcode, lng, lat)

"WRITING" %>% print
write_csv(expanded, 'data/labs-geosearch-pad-normalized.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv', na="")
write_csv(expanded[sample(nrow(expanded), nrow(expanded) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv', na="")

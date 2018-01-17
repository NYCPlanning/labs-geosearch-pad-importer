library(downloader)
library(tidyverse)

source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"

download(source, dest="data/dataset.zip", mode="wb") 
unzip("data/dataset.zip", exdir = "./data")

# LOAD STEP
pad <- read_csv('data/bobaadr.txt')

# CLEANING STEP
pad <- pad %>%
  mutate(boro = str_pad(boro, 1, pad="0")) %>%
  mutate(block = str_pad(block, 5, pad="0")) %>%
  mutate(lot = str_pad(lot, 4, pad="0"))

pad <- pad %>%
  unite(bbl, boro, block, lot, sep="")

# ROW TYPE CLASSIFICATION
pad <- pad %>%
  mutate(
    rowType = case_when(
      addrtype == 'G' | addrtype == 'N' | addrtype == 'X'                                ~ 'nonAddressable',
      grepl("000AA$", lhns) & grepl("000AA$", hhns)                                      ~ 'numericType',
      as.numeric(str_sub(lhns, 7, 9)) > 0 & str_sub(lhns, 10, 11) == "AA" & !is.na(lhns) ~ 'nonNumericDashSepNoSuffix'
    )
  )

# ROW-WISE EXPANSION AND UNNESTING
pad$houseNums <-
  apply(
    pad,
    1,
    function(x) {
      paste(seq(x['lnumber'], x['rnumber'], 2), collapse=',')
    })

pad <- pad %>% 
  mutate(houseNums = strsplit(houseNums, ',')) %>%
  unnest(houseNums)

write.csv(pad, 'data/labs-geosearch-pad-normalized.csv')
write.csv(pad[sample(nrow(pad), nrow(pad) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv')
write.csv(pad[sample(nrow(pad), nrow(pad) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv')
write.csv(pad[sample(nrow(pad), nrow(pad) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv')

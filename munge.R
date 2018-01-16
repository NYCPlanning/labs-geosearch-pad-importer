library(downloader)
library(gdata)
library(tidyr)
library(readr)
library(stringr)
library(dplyr)

source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"

download(source, dest="data/dataset.zip", mode="wb") 
unzip ("data/dataset.zip", exdir = "./data")

pad <- read.csv('data/bobaadr.txt', stringsAsFactors=FALSE)

pad$bbl <- paste(
  str_pad(
    as.character(pad$boro), 1, pad="0"
  ),
  str_pad(
    as.character(pad$block), 5, pad="0"
  ),
  str_pad(
    as.character(pad$lot), 4, pad="0"
  ),
  sep=""
)

# trim whitespace
pad$lhnd <- trim(
  pad$lhnd
)

pad$hhnd <- trim(
  pad$hhnd
)

pad$stname <- trim(
  pad$stname
)

# - Parse house numbers into integers
pad$lnumber <- parse_number(pad$lhnd)
pad$rnumber <- parse_number(pad$hhnd)

# - Count of every odd or even house number based on parity
pad$difference <- (pad$rnumber - pad$lnumber)

# - The difference of any pair of odd or even numbers will always be even. 
pad$interpolatedCount <- ((pad$difference / 2) - 1)

# - Assume addition of two 
pad$finalCount <- pad$interpolatedCount + 2

# - Check this
pad[is.na(pad$rnumber),]$rnumber <- 0
pad[is.na(pad$lnumber),]$lnumber <- 0

pad$houseNums <-
  apply(
    pad,
    1,
    function(x) {
      paste(seq(x['lnumber'], x['rnumber'], 2), collapse=',')
    })

pad <- pad %>% 
  transform(houseNums = strsplit(houseNums, ',')) %>%
  unnest(houseNums)

write.csv(pad, 'data/labs-geosearch-pad-normalized.csv')
write.csv(final[sample(nrow(final), nrow(final) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv')
write.csv(final[sample(nrow(final), nrow(final) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv')
write.csv(final[sample(nrow(final), nrow(final) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv')

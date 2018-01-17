library(downloader)
# library(gdata)
library(tidyverse)
#library(readr)
#library(stringr)
# library(dplyr)

source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"

download(source, dest="data/dataset.zip", mode="wb") 
unzip ("data/dataset.zip", exdir = "./data")

# LOAD STEP
pad <- read.csv('data/bobaadr.txt', stringsAsFactors=FALSE)

# CLEANING STEP
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
pad$lhnd <- trim(pad$lhnd)
pad$hhnd <- trim(pad$hhnd)
pad$lhns <- trim(pad$lhns)
pad$hhns <- trim(pad$hhns)
pad$stname <- trim(pad$stname)

pad[with(pad, lhns == ""),]$lhns <- NA
pad[with(pad, lhnd == ""),]$lhnd <- NA
pad[with(pad, hhnd == ""),]$hhnd <- NA
pad[with(pad, hhns == ""),]$hhns <- NA
pad[with(pad, grepl("", addrtype)),]$addrtype <- NA

# - Parse house numbers into integers
# pad$lnumber <- parse_number(pad$lhnd)
# pad$rnumber <- parse_number(pad$hhnd)

# - Count of every odd or even house number based on parity
pad$difference <- (pad$rnumber - pad$lnumber)

# - The difference of any pair of odd or even numbers will always be even. 
pad$interpolatedCount <- ((pad$difference / 2) - 1)

# - Assume addition of two 
pad$finalCount <- pad$interpolatedCount + 2

# - This should be refactored because it's wrong
# pad[is.na(pad$rnumber),]$rnumber <- 0
# pad[is.na(pad$lnumber),]$lnumber <- 0

# Types:
# - Non-addressable
#     addrtype is G, N, or, X, and there is an addrtype
# - Numeric Range
#     lhns column ends with '000AA$'
# - Non-numeric Range, Letter Suffix
# - Non-numeric Range, Dash-Separated, No Suffix
# - Non-numeric Range, Dash-Separated, With Suffix

# INDICES
nonAddressablePlaces <- with(pad, (((addrtype == 'G') | (addrtype == 'N') | (addrtype == 'X')) & (!is.na(addrtype))))
numericRange <- with(pad, (grepl("000AA$", lhns) & grepl("000AA$", hhns)))
nonNumericDashSepNoSuffix <- 
  with(
    pad,
    (
      (as.numeric(
        str_sub(lhns, 7, 9)
      ) > 0) &
      str_sub(lhns, 10, 11) == "AA" &
      (!is.na(lhns))
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
  transform(houseNums = strsplit(houseNums, ',')) %>%
  unnest(houseNums)

write.csv(pad, 'data/labs-geosearch-pad-normalized.csv')
write.csv(pad[sample(nrow(pad), nrow(pad) * 0.1), ], 'data/labs-geosearch-pad-normalized-sample-lg.csv')
write.csv(pad[sample(nrow(pad), nrow(pad) * 0.05), ], 'data/labs-geosearch-pad-normalized-sample-md.csv')
write.csv(pad[sample(nrow(pad), nrow(pad) * 0.01), ], 'data/labs-geosearch-pad-normalized-sample-sm.csv')

library(downloader)
source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"

# parity field -> evens & odds

download(source, dest="data/dataset.zip", mode="wb") 
unzip ("data/dataset.zip", exdir = "./data")

pad <- read.csv('data/bobaadr.txt')

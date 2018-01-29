source <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/pad17d.zip"
bblcentroids <- "https://planninglabs.carto.com/api/v2/sql?q=SELECT%20bbl,%20Round(ST_X(ST_Centroid(the_geom))::numeric,5)%20AS%20lng,%20Round(ST_Y(ST_Centroid(the_geom))::numeric,5)%20AS%20lat%20FROM%20support_mappluto&format=csv"
bincentroids <- "https://planninglabs.carto.com/api/v2/sql?q=SELECT%20bin%3A%3Atext%2C%20Round%28ST_X%28ST_Centroid%28the_geom%29%29%3A%3Anumeric%2C5%29%20AS%20lng%2C%20Round%28ST_Y%28ST_Centroid%28the_geom%29%29%3A%3Anumeric%2C5%29%20AS%20lat%20FROM%20planninglabs.building_footprints&format=csv"

download(source, dest="data/dataset.zip", mode="wb") 
download(bblcentroids, dest="data/bblcentroids.csv", mode="wb")
download(bincentroids, dest="data/bincentroids.csv", mode="wb")

unzip("data/dataset.zip", exdir = "./data")

# labs-pad-normalize
R script to normalize PAD data into discrete address records

# Introduction
Labs maintains an authoritative [geocoder API](https://github.com/NYCPlanning/labs-geocoder-api) built on Pelias, the geocoding engine that ran Mapzen. To accomplish this, Labs uses authoritative Property Address Directory (PAD) data from the NYC Department of City Planning's Geographic Systems Section. However, because the data represent _ranges_ of addresses, the data must be normalized into an "expanded" form that Pelias will understand. This expansion process involves many factor-specific nuances that translate the ranges into discrete address rows.

# Data
This script downloads a version of the PAD data from [NYC's Bytes of the Big Apple](https://www1.nyc.gov/site/planning/data-maps/open-data.page). The Property Address Directory (PAD) contains geographic information about New York City’s approximately one million tax lots (parcels of real property) and the buildings on them.  PAD was created and is maintained by the Department of City Planning’s (DCP’s) Geographic Systems Section (GSS).  PAD is released under the BYTES of the BIG APPLE product line four times a year, reflecting tax geography changes, new buildings and other property-related changes. 

# R Script
This script will output a file in the `/data` directory called `final.csv`. This is the expanded output. To make sure the script is getting the latest version of PAD, check that the [`source`](https://github.com/NYCPlanning/labs-pad-normalize/blob/master/munge.R#L8) is pointing to the most updated version of PAD. 

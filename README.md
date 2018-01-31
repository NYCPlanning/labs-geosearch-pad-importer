# labs-pad-normalize
R script to normalize PAD data into discrete address records.  Part of the [NYC Geosearch Geocoder Project](https://github.com/NYCPlanning/labs-geosearch-dockerfiles)

# Introduction
The NYC Geosearch API is built on Pelias, the open source geocoding engine that powered Mapzen Search. To accomplish this, Labs uses the authoritative Property Address Directory (PAD) data from the NYC Department of City Planning's Geographic Systems Section. However, because the data represent _ranges_ of addresses, the data must be normalized into an "expanded" form that Pelias will understand. This expansion process involves many factor-specific nuances that translate the ranges into discrete address rows.

<img width="1335" alt="screen shot 2018-01-18 at 2 48 09 pm" src="https://user-images.githubusercontent.com/1833820/35636336-d944fb22-067e-11e8-800c-65ca2100a67b.png">


We are treating the normalization of the PAD data as a separate data workflow from the [PAD Pelias Importer](https://github.com/NYCPlanning/labs-geosearch-pad-importer). This script starts with the published PAD file, and outputs a normalized CSV of discrete addresses, ready to be picked up by the importer.

# Data
This script downloads a version of the PAD data from [NYC's Bytes of the Big Apple](https://www1.nyc.gov/site/planning/data-maps/open-data.page). The Property Address Directory (PAD) contains geographic information about New York City’s approximately one million tax lots (parcels of real property) and the buildings on them.  PAD was created and is maintained by the Department of City Planning’s (DCP’s) Geographic Systems Section (GSS).  PAD is released under the BYTES of the BIG APPLE product line four times a year, reflecting tax geography changes, new buildings and other property-related changes. 

# R Script
This script will output a file in the `/data` directory called `final.csv`. This is the expanded output. To make sure the script is getting the latest version of PAD, check that the [`source`](https://github.com/NYCPlanning/labs-pad-normalize/blob/master/munge.R#L8) is pointing to the most updated version of PAD. 

# Status
The script is incomplete! Find sample output [here](https://github.com/NYCPlanning/labs-pad-normalize/blob/master/pad-sample.csv). Over the coming weeks, it should be finalized. 

# Deploy
To "deploy" data as the source for the geosearch importer, run `npm run deploy`. You must have s3cmd configured as it will run that command to upload output files. To setup for Digital Ocean spaces, see: https://www.digitalocean.com/community/tutorials/how-to-configure-s3cmd-2-x-to-manage-digitalocean-spaces.

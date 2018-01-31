# labs-geosearch-pad-importer

A Pelias Importer for Authoritative NYC Addresses. Part of the [NYC Geosearch Geocoder Project](https://github.com/NYCPlanning/labs-geosearch-dockerfiles)

# Introduction
The NYC Geosearch API is built on Pelias, the open source geocoding engine that powered Mapzen Search.

<img width="1335" alt="screen shot 2018-01-18 at 2 48 09 pm" src="https://user-images.githubusercontent.com/1833820/35636336-d944fb22-067e-11e8-800c-65ca2100a67b.png">



We are treating the normalization of the PAD data as a separate data workflow from Pelias Import. This script picks up the output of [labs-geosearch-pad-normalize](https://github.com/NYCPlanning/labs-geosearch-pad-normalize) and imports it into the Pelias elasticsearch database.



## Requirements

You will need the following things properly installed on your computer.

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (with NPM)
- An elasticsearch database at `localhost:9200` with the pelias index already created
- Pelias API running at `localhost:4000`
- Pelias PIP service with NYC whosonfirst data running at `localhost:4200`. PIP is used to lookup admin boundaries for each record before it enters the database.

## Running the Script

Refer to the README in [labs-geosearch-dockerfiles](https://github.com/NYCPlanning/labs-geosearch-dockerfiles) for more about running the script

The importer has two main functions, downloading the raw data and running the import:

### Download
`npm run download` downloads the normalized pad data and stores in the data directory specified in `pelias.json`

### Import
`npm start` reads the downloaded csv and imports each row into the pelias elasticsearch database.

## Simple Leaflet GUI
To load a simple leaflet map with an autocomplete search control, run `npm run map-test` and point your browser to `http://localhost:8000`.  This simple page expects the pelias API to be running at `http://localhost:4000`

# labs-geosearch-pad-importer

A Pelias Importer for Authoritative NYC Addresses. Part of the [NYC Geosearch Geocoder Project](https://github.com/NYCPlanning/labs-geosearch-docker)

# Introduction
The NYC Geosearch API is built on Pelias, the open source geocoding engine that powers Geocode.earth

<img width="1335" alt="screen shot 2018-01-18 at 2 48 09 pm" src="https://user-images.githubusercontent.com/1833820/35636336-d944fb22-067e-11e8-800c-65ca2100a67b.png">

We are treating the normalization of the PAD data as a separate data workflow from Pelias Import. This script picks up the output of [labs-geosearch-pad-normalize](https://github.com/NYCPlanning/labs-geosearch-pad-normalize) and imports it into the Pelias elasticsearch database.

## Requirements

You will need the following things properly set up to run the importer outside of docker compose. However, it is recommended to use a docker-compose project for simplest standup.

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (with NPM)
- An elasticsearch database with target index already created. Elasticsearch host and index name can be specified in `pelias.json`
  ```javascript
    {
      "esclient": {
        "hosts": [{
          "host": DESIRED_ES_HOST
        }]
      },
      "schema": {
        "indexName": DESIRED_INDEX_NAME
      }
      ... other pelias configuration ...
    }
  ```

## Using the Importer

Running the import includes creating [Documents](https://github.com/pelias/model/blob/master/Document.js) from the `.csv` rows in the normalized PAD source.
The nycpad importer adds custom fields as a `pad_meta` property to the Document objects. New versions of the [pelias schema definition](https://github.com/pelias/schema) specify `dynamic: strict`, meaning the actual writes to ES will fail if using the default pelias schema.
For our solution to extending the pelias schema to include our `pad_meta` fields, see our [custom pelias docker compose project](https://github.com/NYCPlanning/labs-geosearch-dockerfiles)

### Example config:
`imports.nycpad` is required,  `datapath`, and `import` defined as show below
  ```javascript
  {
    "imports": {
      "nycpad": {
        "datapath": "data/nycpad",
        "import": [{
          "filename":"labs-geosearch-pad-normalized.csv"
        }]
      }
    }
    ...
  }
  ```

### Import
`npm start` reads the downloaded csv and imports each row into the pelias elasticsearch database. The importer looks for data at location specified by `datapath` + `import.filename`

## Dockerfile
A Dockerfile is included to enable easy integration of the importer into a docker-compose pelias project. You can read more about docker-compose pelias projects and see examples at https://github.com/pelias/docker

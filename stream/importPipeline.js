'use strict'
var logger = require('pelias-logger').get('nycpad');
var csv = require("fast-csv");

var streams = {};

streams.csvParser = require('./csv_parser').create;
streams.geomLookup = require('./geomLookup');
streams.docConstructor = require('./document_constructor');
streams.adminLookup = require('pelias-wof-admin-lookup').create;
streams.dbMapper = require('pelias-model').createDocumentMapperStream;
streams.elasticsearch = require('pelias-dbclient');

// default import pipeline
streams.import = function(){

  var pluto_lookup = {};
  csv
   .fromPath("./lookup/mappluto_centroids.csv", { headers: true })
   .on("data", function(data){
     var bbl = data.bbl;
     var lng = data.lng;
     var lat = data.lat;

     pluto_lookup[bbl] = [lng, lat];
   })
   .on("end", function(){
     streams.csvParser()
       .pipe( streams.geomLookup(pluto_lookup) )
       .pipe( streams.docConstructor() )
       .pipe( streams.adminLookup() )
       .pipe( streams.dbMapper() )
       .pipe( streams.elasticsearch() );
   });f
};

module.exports = streams;

var streams = {};

streams.csvParser = require('./csv_parser').create;
streams.docConstructor = require('./document_constructor');
streams.addParentData = require('./adminLookup');
streams.dbMapper = require('pelias-model').createDocumentMapperStream;
streams.elasticsearch = require('pelias-dbclient');

// default import pipeline
streams.import = function(){
   streams.csvParser()
     .pipe( streams.docConstructor() )
     .pipe( streams.addParentData() )
     .pipe( streams.dbMapper() )
     .pipe( streams.elasticsearch({ batchSize: 1}) );
};

module.exports = streams;

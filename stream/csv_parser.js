var combinedStream = require('combined-stream');
// var pbf = require('./pbf');
var csv = require("fast-csv");
var path = require('path');
var logger = require('pelias-logger').get('nycpad');

function createCombinedStream(){
  var fullStream = combinedStream.create();
  var defaultPath= require('pelias-config').generate().imports.nycpad;

  defaultPath.import.forEach(function( importObject){
    var conf = {file: path.join(defaultPath.datapath, importObject.filename), leveldb: defaultPath.leveldbpath};
    fullStream.append(function(next){
      logger.info('Creating read stream for: ' + conf.file);
      next(csv.fromPath('/data/nycpad/bobaadr.txt', {
        headers: true,
      }));
    });
  });

  return fullStream;
}

module.exports.create = createCombinedStream;

var combinedStream = require('combined-stream');
var csv = require('fast-csv');
var path = require('path');
var logger = require('pelias-logger').get('nycpad');

function createCombinedStream(){
  var fullStream = combinedStream.create();
  var defaultPath= require('pelias-config').generate().imports.nycpad;

  defaultPath.import.forEach(function( importObject){
    var file = path.join(defaultPath.datapath, importObject.filename);
    fullStream.append(function(next){
      logger.info('Creating read stream for: ' + file);
      next(csv.fromPath(file, {
        headers: true,
      }));
    });
  });

  return fullStream;
}

module.exports.create = createCombinedStream;

'use strict';

var _ = require('lodash');
var child_process = require('child_process');
var fs = require('fs-extra');
var config = require( 'pelias-config' ).generate(require('../schema'));
var logger = require('pelias-logger').get('download');

if (require.main === module) {
  download(function(err) {
    if (err) {
      logger.error('Failed to download data', err);
      process.exit(1);
    }
    logger.info('All done!');
  });
}

function download(callback) { // jshint ignore:line
  var scriptFile = config.imports.nycpad.scriptFile;
  var outputPath = config.imports.nycpad.outputPath;
  var leveldbpath = config.imports.nycpad.leveldbpath; // jshint ignore:line
  var datapath = config.imports.nycpad.datapath;
  var scriptDir = config.imports.nycpad.scriptDir;

  if (_.isEmpty(scriptFile)) {
    logger.error('Error: Must configure scriptFile');
  }

  logger.info('Running script for nycpad: ' + scriptFile);

  fs.ensureDir(datapath, function(err) {
    if (err) {
      logger.error('error making directory ', datapath, err);
      return callback(err);
    }

    var command = 'cd ' + scriptDir + ' && RScript ' + scriptFile + ' && cd .. && mv ' + outputPath + ' ' + datapath;

    child_process
      .exec(command, callback);
  });
}

module.exports = download;

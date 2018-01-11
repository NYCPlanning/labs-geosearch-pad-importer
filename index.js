var peliasConfig = require('pelias-config').generate(require('./schema')); // jshint ignore:line
var _ = require('lodash'); // jshint ignore:line
var logger = require('pelias-logger').get('nycpad'); // jshint ignore:line

var importPipeline = require('./stream/importPipeline');

importPipeline.import();

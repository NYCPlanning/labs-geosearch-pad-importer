const peliasConfig = require('pelias-config').generate(require('./schema'));
const _ = require('lodash');
const logger = require('pelias-logger', {
  level: 'verbose'
}).get('nycpad');

const importPipeline = require('./stream/importPipeline');

importPipeline.import();

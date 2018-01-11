'use strict';

var Joi = require('joi');

// Schema Configuration
// datapath: string (required)
// leveldbpath: string (required)
// import: array of objects containing filename (optional)
// download: array of objects containing sourceURL (optional)
// deduplicate: boolean (optional)
module.exports = Joi.object().keys({
  imports: Joi.object().keys({
    nycpad: Joi.object().keys({
      scriptFile: Joi.string(),
      outputPath: Joi.string(),
      leveldbpath: Joi.string(),
      datapath: Joi.string(),
      scriptDir: Joi.string(),
      import: Joi.array().items(Joi.object().keys({
        filename: Joi.string()
      }).requiredKeys('filename').unknown(true)),
      download: Joi.array().items(Joi.object().keys({
        sourceURL: Joi.string()
      }).requiredKeys('sourceURL').unknown(true)),
      deduplicate: Joi.boolean()
    }).requiredKeys('datapath', 'leveldbpath', 'import').unknown(true)
  }).requiredKeys('nycpad').unknown(true)
}).requiredKeys('imports').unknown(true);


/**
  The document constructor is responsible for mapping input data from the parser
  in to model.Document() objects which the rest of the pipeline expect to consume.
**/

var through = require('through2');
var Document = require('pelias-model').Document;
// override Document.toESDocument to allow custom pad_meta fields to get shipped to ES
Document.prototype.toESDocument = require('./to_es_document.js');

var peliasLogger = require( 'pelias-logger' ).get( 'nycpad' );

module.exports = function(){
  var i = 0;
  var stream = through.obj( function( item, enc, next ) {

    try {
      // create new Document with source=nycpad, type=address
      var doc = new Document( 'nycpad', 'address', i++);

      // set lat & long
      if( item.hasOwnProperty('lat') && item.hasOwnProperty('lng') ){
        doc.setCentroid({
          lat: item.lat,
          lon: item.lng,
        });
      }

      // set name
      doc.name = {
        default: `${item.houseNum ? item.houseNum + ' ' : ''}${item.stname}`.trim()
      };

      // set phrase
      doc.phrase = {
        default: `${item.houseNum ? item.houseNum + ' ' : ''}${item.stname}`.trim()
      };

      // set address parts
      doc.address_parts = {
        number: item.houseNum,
        street: item.stname,
        zip: item.zipcode
      };

      // set meta fields from PAD
      doc.pad_meta = {
        pad_low: item.pad_low,
        pad_high: item.pad_high,
        pad_bin: item.pad_bin,
        pad_bbl: item.pad_bbl,
        pad_geomtype: item.pad_geomtype,
        pad_orig_stname: item.pad_orig_stname
      };

      // Push instance of Document downstream
      this.push( doc );
    }

    catch( e ){
      peliasLogger.error( 'error constructing document model', e.stack );
    }

    return next();

  });

  // catch stream errors
  stream.on( 'error', peliasLogger.error.bind( peliasLogger, __filename ) );

  return stream;
};

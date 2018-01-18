
/**
  The document constructor is responsible for mapping input data from the parser
  in to model.Document() objects which the rest of the pipeline expect to consume.
**/

var through = require('through2');
var Document = require('pelias-model').Document;

// override Document.toESDocument so that the meta object
Document.prototype.toESDocument = require('./to_es_document.js');

var peliasLogger = require( 'pelias-logger' ).get( 'nycpad' );

module.exports = function(){
  var i = 0;
  var stream = through.obj( function( item, enc, next ) {

    try {
      // if (!item.type || ! item.id) {
      //   throw new Error('doc without valid id or type');
      // }
      var uniqueId = i;

      // we need to assume it will be a venue and later if it turns out to be an address it will get changed
      var doc = new Document( 'nycpad', 'address', uniqueId );

      if( item.hasOwnProperty('lat') && item.hasOwnProperty('lng') ){
        doc.setCentroid({
          lat: item.lat,
          lon: item.lng,
        });
      }

      doc.name = {
        default: `${item.houseNum ? item.houseNum + ' ' : ''}${item.stname}`.trim()
      };

      doc.phrase = {
        default: `${item.houseNum ? item.houseNum + ' ' : ''}${item.stname}`.trim()
      };

      doc.address_parts = {
        number: item.houseNum,
        street: item.stname,
        zip: item.zipcode
      };

      doc.setMeta('bbl', item.bbl);

      // Push instance of Document downstream
      this.push( doc );
      i += 1;
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


/**
  The document constructor is responsible for mapping input data from the parser
  in to model.Document() objects which the rest of the pipeline expect to consume.
**/

var through = require('through2');
var Document = require('pelias-model').Document;
var peliasLogger = require( 'pelias-logger' ).get( 'openstreetmap' );
var _ = require('lodash');

module.exports = function(){
  let i = 0;
  var stream = through.obj( function( item, enc, next ) {
    Object.keys(item).forEach((property) => {
      item[property] = item[property].trim();
    });

    try {
      // if (!item.type || ! item.id) {
      //   throw new Error('doc without valid id or type');
      // }
      var uniqueId = i;

      // we need to assume it will be a venue and later if it turns out to be an address it will get changed
      var doc = new Document( 'nycpad', 'address', uniqueId );

      // Set dummy latitude / longitude
      // if( item.hasOwnProperty('lat') && item.hasOwnProperty('lon') ){
        doc.setCentroid({
          lat: 40.7128,
          lon: -74.0060
        });
      // }

        doc.name = {
          default: `${item.lhnd} ${item.stname}`.trim()
        }

        doc.phrase = {
          default: `${item.lhnd} ${item.stname}`.trim()
        }

        doc.address_parts = {
          number: item.lhnd,
          street: item.stname,
          zip: item.zipcode
        },

      // Set latitude / longitude (for ways where the centroid has been precomputed)
      // else if( item.hasOwnProperty('centroid') ){
      //   if( item.centroid.hasOwnProperty('lat') && item.centroid.hasOwnProperty('lon') ){
      //     doc.setCentroid({
      //       lat: item.centroid.lat,
      //       lon: item.centroid.lon
      //     });
      //   }
      // }

      // Set noderefs (for ways)
      // if( item.hasOwnProperty('nodes') ){
      //   doc.setMeta( 'nodes', item.nodes );
      // }

      // Store osm tags as a property inside _meta
      // doc.setMeta( 'tags', item.tags || {} );

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

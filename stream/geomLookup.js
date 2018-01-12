'use strict'

/**
  Looks up lat/lng coordinates for a bbl
**/
var through = require('through2');
var peliasLogger = require( 'pelias-logger' ).get( 'nycpad' );
var _ = require('lodash');


module.exports = function(pluto_lookup){
  var stream = through.obj( function( item, enc, next ) {
    try {
      var boro = item.boro;
      var block = item.block;
      var lot = item.lot;

      var bbl = item.bbl;
      console.log(bbl);

      var coords = pluto_lookup[bbl];
      item.lng = coords[0];
      item.lat = coords[1];

      this.push( item );
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

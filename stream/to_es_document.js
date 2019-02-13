var config = require('pelias-config').generate();

module.exports = function() {
  var doc = {
    name: this.name,
    phrase: this.phrase,
    parent: this.parent,
    address_parts: this.address_parts,
    center_point: this.center_point,
    category: this.category,
    source: this.source,
    layer: this.layer,
    source_id: this.source_id,
    bounding_box: this.bounding_box,
    popularity: this.popularity,
    population: this.population,
    polygon: this.shape,
    pad_meta: this.pad_meta
  };

  // remove empty properties
  if( !Object.keys( doc.parent || {} ).length ){
    delete doc.parent;
  }
  if( !Object.keys( doc.address_parts || {} ).length ){
    delete doc.address_parts;
  }
  if( !( this.category || [] ).length ){
    delete doc.category;
  }
  if (!this.bounding_box) {
    delete doc.bounding_box;
  }
  if( !Object.keys( doc.center_point || {} ).length ){
    delete doc.center_point;
  }
  if (!this.population) {
    delete doc.population;
  }
  if (!this.popularity) {
    delete doc.popularity;
  }
  if( !Object.keys( doc.polygon || {} ).length ){
    delete doc.polygon;
  }

  return {
    _index: config.schema.indexName,
    _type: this.getType(),
    _id: this.getId(),
    data: doc
  };
};

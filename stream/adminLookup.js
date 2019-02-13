const through = require('through2');

const peliasLogger = require('pelias-logger').get('nycpad');

const boroughIdToAdmin = {
  1: {
    borough: 'Manhattan',
    county: 'New York County',
    fips: '061',
  },
  2: {
    borough: 'Bronx',
    county: 'Bronx County',
    fips: '005',
  },
  3: {
    borough: 'Brooklyn',
    county: 'Kings County',
    fips: '047',
  },
  4: {
    borough: 'Queens',
    county: 'Queens County',
    fips: '081',
  },
  5: {
    borough: 'Staten Island',
    county: 'Richmond County',
    fips: '085',
  },
};

function bblToBoroughId(bbl = '') {
  if (typeof bbl === 'string' || typeof bbl === 'number') {
    const bblString = bbl.toString();
    return bblString.substring(0, 1);
  }
  return null;
}

function addParentData() {
  const stream = through.obj(function (doc, enc, next) {
    try {
      doc.addParent('country', 'United States', '85633793', 'USA');

      doc.addParent('locality', 'New York', '0', 'NYC');

      doc.addParent('region', 'New York State', '0', 'NY');

      const boroughId = bblToBoroughId(doc.pad_meta.pad_bbl);

      const { borough, county, fips } = boroughIdToAdmin[boroughId];
      try {
        doc.addParent('borough', borough, boroughId);
        doc.addParent('county', county, fips);
      /* addParent throws an error if any parent fields are missing.
        We are not supplying abbreviations for borough or county,
        so we silently swalloe the PeliasModelError */
      } catch (e) {} // eslint-disable-line

      this.push(doc);
    } catch (e) {
      peliasLogger.error('error adding admin (parent) fields', e.stack);
    }

    return next();
  });

  stream.on('error', peliasLogger.error.bind(peliasLogger, __filename));

  return stream;
}

module.exports = addParentData;

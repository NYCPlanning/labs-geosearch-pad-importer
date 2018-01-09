# Authoritative NYC Address Data for the Pelias Geocoder

This package imports authoritative NYC address data from the [Property Address Directory (PAD)](https://www1.nyc.gov/site/planning/data-maps/open-data.page#pad) into [Pelias](https://github.com/pelias/pelias) (A modular, open-source geocoder built on top of ElasticSearch for fast geocoding).

## How we work

[NYC Planning Labs](https://planninglabs.nyc) takes on a single project at a time, working closely with our customers from concept to delivery in a matter of weeks.  We conduct regular maintenance between larger projects.  

Take a look at our sprint planning board {link to waffle} to get an idea of our current priorities for this project.

## How you can help

In the spirit of free software, everyone is encouraged to help improve this project.  Here are some ways you can contribute.

- Comment on or clarify [issues](link to issues)
- Report [bugs](link to bugs)
- Suggest new features
- Write or edit documentation
- Write code (no patch is too small)
  - Fix typos
  - Add comments
  - Clean up code
  - Add new features

**[Read more about contributing.](CONTRIBUTING.md)**

## Requirements

You will need the following things properly installed on your computer.

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (with NPM)
- An elasticsearch database at `localhost:9200` with the pelias index already created
- Pelias API running at `localhost:4000`
- Pelias PIP service with NYC whosonfirst running at `localhost:4200`. PIP is used to lookup admin boundaries for each record before it enters the database.

## Local development

- Clone this repo `git clone git@github.com:NYCPlanning/labs-geocoder-api.git`
- Install Dependencies `npm install`

To download PAD data, use `PELIAS_CONFIG=./config/pelias.json npm run download`
To run the importer, use `PELIAS_CONFIG=./config/pelias.json npm start`

## Architecture

{"Lay of the land" structure of the codebase, components...}


## Testing and checks

- **ESLint** - We use ESLint with Airbnb's rules for JavaScript projects
  - Add an ESLint plugin to your text editor to highlight broken rules while you code
  - You can also run `eslint` at the command line with the `--fix` flag to automatically fix some errors.

## Deployment

{Description of what type of hosting environment is required, and steps for how Labs deploys -- e.g `git push dokku master`.}

## Contact us

You can find us on Twitter at [@nycplanninglabs](https://twitter.com/nycplanninglabs), or comment on issues and we'll follow up as soon as we can. If you'd like to send an email, use [labs_dl@planning.nyc.gov](mailto:labs_dl@planning.nyc.gov)

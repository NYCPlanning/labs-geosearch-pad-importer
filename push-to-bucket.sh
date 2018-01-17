#!/bin/bash
Rscript ./munge.R

zip data/labs-geosearch-pad-normalized.zip data/labs-geosearch-pad-normalized.csv 
zip data/labs-geosearch-pad-normalized-sample-lg.zip data/labs-geosearch-pad-normalized-sample-lg.csv
zip data/labs-geosearch-pad-normalized-sample-md.zip data/labs-geosearch-pad-normalized-sample-md.csv
zip data/labs-geosearch-pad-normalized-sample-sm.zip data/labs-geosearch-pad-normalized-sample-sm.csv

s3cmd put data/labs-geosearch-pad-normalized*.zip s3://planninglabs/geosearch-data/
s3cmd setacl s3://planninglabs/geosearch-data/ --acl-public --recursive

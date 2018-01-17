#!/bin/bash
Rscript ./munge.R

cd data
zip labs-geosearch-pad-normalized.zip labs-geosearch-pad-normalized.csv 
zip labs-geosearch-pad-normalized-sample-lg.zip labs-geosearch-pad-normalized-sample-lg.csv
zip labs-geosearch-pad-normalized-sample-md.zip labs-geosearch-pad-normalized-sample-md.csv
zip labs-geosearch-pad-normalized-sample-sm.zip labs-geosearch-pad-normalized-sample-sm.csv
cd ..

s3cmd put data/labs-geosearch-pad-normalized*.zip s3://planninglabs/geosearch-data/
s3cmd setacl s3://planninglabs/geosearch-data/ --acl-public --recursive

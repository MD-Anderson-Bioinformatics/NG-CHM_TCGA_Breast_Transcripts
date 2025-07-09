#!/bin/bash
##
## Bash script to collect data for the NG-CHM at:
##  https://tcga.ngchm.net/NGCHM/chm.html?map=48a854d220343348b732e30061aa9a00d2e2ba28
##

set -x
set -e

BASE_URL="https://maps.ngchm.net/api/tar/"

# function to download and extract a file from the NG-CHM server
get_file() {
  URL=$1
  shaid=$2
  sub_directory=$3
  mkdir -p ${sub_directory}/${shaid}
  cd ${sub_directory}/${shaid}
  curl -o tmp.tar "${URL}/${shaid}"
  tar -xvf tmp.tar
  rm tmp.tar
  cd ../..
}

# Get chm.json file for main map. This file contains the SHA IDs for the map data.
main_shaid="48a854d220343348b732e30061aa9a00d2e2ba28"
mkdir -p ${main_shaid}
curl -o main.tar "${BASE_URL}/chm/${main_shaid}"
tar -xvf main.tar -C ${main_shaid}

## Get each of the three data layer matrices, using the SHA IDs from the main chm.json file.
for i in {0..2}; do
  matrix_layer_shaid=`jq ".layers[$i].data.value" ${main_shaid}/chm.json | sed 's/\"//g'`
  get_file "${BASE_URL}/dataset" "${matrix_layer_shaid}" data_layers
  echo "Matrix layers:"
  echo ${matrix_layers}
done

## Get data for the 27 column covariates, using the SHA IDs from the main chm.json file.
for i in {0..26}; do
  column_covariate_shaid=`jq ".col_data.covariates[$i].data.value" ${main_shaid}/chm.json | sed 's/\"//g'`
  echo "Column covariate shaid: ${column_covariate_shaid}"
  get_file "${BASE_URL}/dataset" "${column_covariate_shaid}" col_covariates
done

## Get data for the 3 row covariates, using the SHA IDs from the main chm.json file.
for i in {0..2}; do
  row_covariate_shaid=`jq ".row_data.covariates[$i].data.value" ${main_shaid}/chm.json | sed 's/\"//g'`
  echo "Column covariate shaid: ${row_covariate_shaid}"
  get_file "${BASE_URL}/dataset" "${row_covariate_shaid}" row_covariates
done


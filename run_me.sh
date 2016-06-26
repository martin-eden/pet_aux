#!/bin/bash

# if not mappings
#   build mappings
# for each auction from config
#   download auctions data
#   process and update current results (with pet list from config)
# print result

## Set api_key, fiel names and mode
api_key="p8sg9fnpz5sh859urt92vaanbc6ztmj2"
locale="en_GB"

config_lua="./config.lua"
results_lua="./results.lua"
results_tmp="${results}.tmp"
use_cache=false
if [[ $1 = "--use-cache" ]]
then
  echo "Previously auctions used. No auctions data will be downloaded."
  use_cache=true
fi

set -e
mkdir -p ./data

## Get realms
function get_realms
{
  local realms_json=$1
  if [[ ! -e $realms_json ]]
  then
    echo "Getting realms list..."
    local realms_url="https://eu.api.battle.net/wow/realm/status?locale=$locale&apikey=$api_key"
    wget \
      --no-clobber \
      --output-document=$realms_json \
      --quiet \
      $realms_url
  fi
}

function prepare_realms
{
  local realms_lua=$1
  if [[ ! -e $realms_lua ]]
  then
    local realms_json="./data/realms.json"
    get_realms $realms_json
    echo "  Building realms list."
    cd ./lua
    lua ./auction_realms_list.lua ../$realms_json > ../$realms_lua
    cd ..
  fi
}

realms_lua="./data/realms.lua"
prepare_realms $realms_lua

## Get species
function get_species
{
  local species_json=$1
  if [[ ! -e $species_json ]]
  then
    echo "Getting pet list..."
    local species_url="https://eu.api.battle.net/wow/pet/?locale=$locale&apikey=$api_key"
    wget \
      --no-clobber \
      --output-document=$species_json \
      --quiet \
      $species_url
  fi
}

function prepare_species
{
  local species_lua=$1
  if [[ ! -e $species_lua ]]
  then
    local species_json="./data/species.json"
    get_species $species_json
    echo "  Building pet list."
    cd ./lua
    lua ./pet_species_list.lua ../$species_json > ../$species_lua
    cd ..
  fi
}

species_lua="./data/species.lua"
prepare_species $species_lua

## Get auctions and extract species
rm --force $results_lua
echo "return {}" > $results_lua
cd ./lua
lua ./print_realm_slugs_from_config.lua ../$config_lua ../$realms_lua | \
while read servname; do
  link_file="./data/${servname}_link.json"
  if $use_cache && [[ -e ../$link_file ]]
  then
    echo "Using old link to '$servname'."
  else
    echo "Getting link to realm '$servname'."
    rm --force ../$link_file
    # auc_link_url="http://eu.battle.net/api/wow/auction/data/$servname"
    auc_link_url="https://eu.api.battle.net/wow/auction/data/$servname?locale=en_GB&apikey=$api_key"
    wget \
      --no-clobber \
      --output-document=../$link_file \
      --quiet \
      $auc_link_url
  fi
  url_and_name=($(lua ./suggest_filename.lua ../$link_file))
  auc_url=${url_and_name[0]}
  auc_json="../data/auc_${url_and_name[1]}"
  if [[ ! -e $auc_json ]]
  then
    rm --force ../data/auc_*$servname*.json
    echo "  Getting actual auction data..."
    wget \
      --no-clobber \
      --output-document=../data/$auc_json \
      --quiet \
      $auc_url
  else
    echo "  File already retrieved. Using it."
  fi
  lua ./auc_extreme_pet_prices.lua $auc_json ../$config_lua ../$species_lua ../$results_lua > ../$results_tmp
  cat ../$results_tmp > ../$results_lua
done
cd ..
rm --force $results_tmp
echo "Results are in '$results_lua'"

# cd ./lua
# lua ./display_results.lua ../results.lua 3 | egrep --after-context=3 "\(1\)\s+Ford"

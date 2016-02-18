#!/bin/bash

# 1. if not mappings
# 2.   build mappings
# 3. for each auction from config
# 4.   download auctions data
# 5.   process and update current results (with pet list from config)
# 6. print result

# 0.
api_key="s8gmc6zepuh5ncjky5wzquwxzkx9zx2f"
locale="en_GB"
config="./config.lua"
results="./results.lua"
results_tmp="${results}.tmp"
use_cache=false
if [[ $1 = "--use-cache" ]]
then
  echo "Previously auctions used. No auctions data will be downloaded."
  use_cache=true
fi

# 1.
## Get realms
realms_out="./data/realms.lua"
if [[ ! -e $realms_out ]]
then
  # 2.
  realms_json="./data/realms.json"
  if [[ ! -e $realms_json ]]
  then
    realms_url="https://eu.api.battle.net/wow/realm/status?locale=$locale&apikey=$api_key"
    echo "Getting realms list..."
    wget \
      --no-clobber \
      --output-document=$realms_json \
      --quiet \
      $realms_url
  fi
  echo "  Building realms list."
  cd ./lua
  lua ./auction_realms_list.lua ../$realms_json > ../$realms_out
  cd ..
fi

## Get species
species_out="./data/species.lua"
if [[ ! -e $species_out ]]
then
  # 2.
  species_json="./data/species.json"
  if [[ ! -e $species_json ]]
  then
    species_url="https://eu.api.battle.net/wow/pet/?locale=$locale&apikey=$api_key"
    echo "Getting pet list..."
    wget \
      --no-clobber \
      --output-document=$species_json \
      --quiet \
      $species_url
  fi
  echo "  Building pet list."
  cd ./lua
  lua ./pet_species_list.lua ../$species_json > ../$species_out
  cd ..
fi

# 3.
rm --force $results
echo "return {}" > $results
cd ./lua
lua ./print_realm_slugs_from_config.lua ../$config ../$realms_out | \
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
  auc_file="../data/auc_${url_and_name[1]}"
  if [[ ! -e $auc_file ]]
  then
    rm --force ../data/auc_*$servname*.json
    echo "  Getting actual auction data..."
    wget \
      --no-clobber \
      --output-document=../data/$auc_file \
      --quiet \
      $auc_url
  else
    echo "  File already retrieved. Using it."
  fi
  lua ./auc_extreme_pet_prices.lua $auc_file ../$config ../$species_out ../$results > ../$results_tmp
  cat ../$results_tmp > ../$results
done
cd ..
rm --force $results_tmp
echo "Results are in '$results'"

# cd ./lua
# lua ./display_results.lua ../results.lua 3 | egrep --after-context=3 "\(1\)\s+Ford"

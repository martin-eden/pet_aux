#!/bin/bash

# if not mappings
#   build mappings
# for each auction from config
#   download auctions data
#   process and update current results (with pet list from config)
# print result

use_cache=false
if [[ $1 = "--use-cache" ]]
then
  echo "Previously auctions used. No auctions data will be downloaded."
  use_cache=true
fi

home_dir=`pwd`

export data_path=$home_dir/data
export lua_path=$home_dir/lua
export bash_path=$home_dir/bash

bash $bash_path/create_directories.sh

cd lua

# set -e


function convert
{
  local input_file=$1
  local output_file=$2
  lua json_to_lua.lua $input_file $output_file
}

function get_tmp_name
{
  echo $data_path/tmp/$(basename $1)
}

function get_json_name
{
  echo $data_path/json/$(basename $1 .json).json
}

function get_converted_name
{
  echo $data_path/converted/$(basename $1 .json).lua
}

function get_filtered_name
{
  echo $data_path/filtered/$(basename $1)
}

function retrieve
{
  $bash_path/retrieve.sh $1 $2
}

## Set api_key, field names and mode
api_key="p8sg9fnpz5sh859urt92vaanbc6ztmj2"
locale="en_GB"

## Get realms
echo -n "Getting realms list... "
realms_json=$(get_json_name realms.json)
if [[ -e $realms_json ]]
then
  echo "already done"
else
  realms_url="https://eu.api.battle.net/wow/realm/status?locale=$locale&apikey=$api_key"
  retrieve $realms_url $realms_json
  echo "done"
fi

echo -n "Converting realms... "
realms_lua=$(get_converted_name $realms_json)
if [[ -e $realms_lua ]]
then
  echo "already done"
else
  convert $realms_json $realms_lua
  echo "done"
fi

echo -n "Mapping realms... "
realms_map=$(get_filtered_name $realms_lua)
if [[ -e $realms_map ]]
then
  echo "already done"
else
  lua map_realms.lua $realms_lua $realms_map
  echo "done"
fi

## Get species

species_json=$(get_json_name species.json)
echo -n "Getting pet list... "
if [[ -e $species_json ]]
then
  echo "already done"
else
  species_url="https://eu.api.battle.net/wow/pet/?locale=$locale&apikey=$api_key"
  retrieve $species_url $species_json
  echo "done"
fi

echo -n "Converting pet list... "
species_lua=$(get_converted_name $species_json)
if [[ -e $species_lua ]]
then
  echo "already done"
else
  convert $species_json $species_lua
  echo "done"
fi

species_map=$(get_filtered_name $species_lua)
echo -n "Filtering species... "
if [[ -e $species_map ]]
then
  echo "already done"
else
  lua pet_species_list.lua $species_lua $species_map
  echo "done"
fi

## Get auctions and extract species
results_lua="../results.lua"
config_lua="../config.lua"
results_tmp=$results.tmp
echo "{}" > $results_lua
lua print_realm_slugs_from_config.lua $config_lua $realms_map | \
while read servname; do
  json_link_file=$(get_json_name $servname)
  if $use_cache && [[ -e $json_link_file ]]
  then
    echo "Using link to realm '$servname' from cache."
  else
    echo "Getting link to realm '$servname'."
    # We must retrieve this file as it contains last auction time
    # non-auth link was "http://eu.battle.net/api/wow/auction/data/$servname"
    auc_link_url="https://eu.api.battle.net/wow/auction/data/$servname?locale=$locale&apikey=$api_key"
    retrieve $auc_link_url $json_link_file
  fi

  echo -n "  Converting to lua... "
  lua_link_file=$(get_converted_name $json_link_file)
  convert $json_link_file $lua_link_file
  echo "done"

  url_and_name=($(lua suggest_filename.lua $lua_link_file))
  auc_url=${url_and_name[0]}
  json_auc_name=$(get_json_name ${url_and_name[1]})
  echo -n "  Getting actual auction data... "
  if [[ -e $json_auc_name ]]
  then
    echo "already done"
  else
    retrieve $auc_url $json_auc_name
    echo "done"
  fi

  echo -n "  Converting to lua... "
  lua_auc_name=$(get_converted_name $json_auc_name)
  if [[ -e $lua_auc_name ]]
  then
    echo "already done"
  else
    convert $json_auc_name $lua_auc_name
    echo "done"
  fi

  echo -n "  Filtering... "
  lua_filtered_auc_name=$(get_filtered_name $lua_auc_name)
  if [[ -e $lua_filtered_auc_name ]]
  then
    echo "already done"
  else
    lua filter_auctions.lua $lua_auc_name $lua_filtered_auc_name
    echo "done"
  fi

  echo -n "  Processing... "
  lua auc_extreme_pet_prices.lua \
    $lua_filtered_auc_name $config_lua $species_map $results_lua > $results_tmp
  if [[ -s $results_tmp ]]
  then
    cat $results_tmp > $results_lua
  fi
  echo "done"
done
rm --force $results_tmp
echo "Results are in '$results_lua'"

# cd ./lua
# lua ./display_results.lua ../results.lua 3 | egrep --after-context=3 "\(1\)\s+Ford"

cd ..

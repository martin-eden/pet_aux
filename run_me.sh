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

## Set api_key, field names and mode
export api_key="p8sg9fnpz5sh859urt92vaanbc6ztmj2"
export locale="en_GB"

bash $bash_path/create_directories.sh

cd lua

# set -e

function convert
{
  local input_file=$1
  local output_file=$2
  lua json_to_lua.lua $input_file $output_file
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
  bash $bash_path/retrieve.sh $1 $2
}

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

export species_map=$(get_filtered_name $species_lua)
echo -n "Filtering species... "
if [[ -e $species_map ]]
then
  echo "already done"
else
  lua pet_species_list.lua $species_lua $species_map
  echo "done"
fi


## Get auctions and extract species
export results_lua="$home_dir/results.lua"
export config_lua="$home_dir/config.lua"
echo "{}" > $results_lua

echo "Parallel loading and processing auctions."

lua print_realm_slugs_from_config.lua $config_lua $realms_map | \
parallel -j50 bash $bash_path/get_realm_link.sh | \
parallel bash $bash_path/link_converter.sh | \
parallel -j20 bash $bash_path/auc_getter.sh | \
parallel bash $bash_path/auc_converter.sh | \
parallel bash $bash_path/auc_filterer.sh | \
parallel -j1 bash $bash_path/results_merger.sh

echo "Results are in '$results_lua'"

# cd ./lua
# lua ./display_results.lua ../results.lua 3 | egrep --after-context=3 "\(1\)\s+Ford"

cd ..

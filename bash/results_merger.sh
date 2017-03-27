function get_dest_name
{
  echo $data_path/results_merger/$(basename $1 .lua).lua
}

function get_processed_name
{
  echo $data_path/results_merger/processed/$(basename $1)
}

if [[ ! -e $1 ]]
then
  exit
fi
filtered_auc_name=$1
results_tmp=`mktemp`
# echo "filtered_auc_name $filtered_auc_name"
# echo "config_lua $config_lua"
# echo "species_map $species_map"
# echo "results_lua $results_lua"
# echo "results_tmp $results_tmp"
lua auc_extreme_pet_prices.lua \
  $filtered_auc_name $config_lua $species_map $results_lua > $results_tmp
if [[ -s $results_tmp ]]
then
  mv $results_tmp $results_lua
fi
mv $filtered_auc_name $data_path/auc_filterer/processed

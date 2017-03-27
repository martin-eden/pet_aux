function get_dest_name
{
  echo $data_path/auc_filterer/$(basename $1 .lua).lua
}

function get_processed_name
{
  echo $data_path/auc_filterer/processed/$(basename $1)
}

if [[ ! -e $1 ]]
then
  exit
fi
lua_auc_name=$1
# echo "Lua auc file: $lua_auc_name"
dest_name=$(get_dest_name $lua_auc_name)
processed_name=$(get_processed_name $dest_name)
if [[ ! -e $dest_name ]] && [[ ! -e $processed_name ]]
then
  lua filter_auctions.lua $lua_auc_name $dest_name
  echo $dest_name
fi
mv $lua_auc_name $data_path/auc_converter/processed

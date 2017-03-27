function get_dest_name
{
  echo $data_path/auc_converter/$(basename $1 .json).lua
}

function get_processed_name
{
  echo $data_path/auc_converter/processed/$(basename $1)
}

if [[ ! -e $1 ]]
then
  exit
fi
json_auc_name=$1
# echo "JSON auc file: $json_auc_name"
dest_name=$(get_dest_name $json_auc_name)
processed_name=$(get_processed_name $dest_name)
if [[ ! -e $dest_name ]] && [[ ! -e $processed_name ]]
then
  lua json_to_lua.lua $json_auc_name $dest_name
  echo $dest_name
fi
mv $json_auc_name $data_path/auc_loader/processed

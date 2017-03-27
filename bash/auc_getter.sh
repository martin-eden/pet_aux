function get_dest_name
{
  echo $data_path/auc_loader/$(basename $1 .json).json
}

function get_processed_name
{
  echo $data_path/auc_loader/processed/$(basename $1)
}

if [[ ! -e $1 ]]
then
  exit
fi
lua_link_file=$1
url_and_name=($(lua suggest_filename.lua $lua_link_file))
auc_url=${url_and_name[0]}
dest_file=$(get_dest_name ${url_and_name[1]})
processed_file=$(get_processed_name $dest_file)
if [[ ! -e $dest_file ]] && [[ ! -e $processed_file ]]
then
  bash $bash_path/retrieve.sh $auc_url $dest_file
  echo $dest_file
fi
mv $lua_link_file $data_path/link_converter/processed

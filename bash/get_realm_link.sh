function get_dest_name
{
  echo $data_path/link_getter/$(basename $1).json
}

servname=$1
dest_file=$(get_dest_name $servname)
# Non-auth link version was "http://eu.battle.net/api/wow/auction/data/$servname"
auc_link_url="https://eu.api.battle.net/wow/auction/data/$servname?locale=$locale&apikey=$api_key"
bash $bash_path/retrieve.sh $auc_link_url $dest_file
echo $dest_file

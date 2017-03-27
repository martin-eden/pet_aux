function get_dest_name
{
  echo $data_path/link_converter/$(basename $1 .json).lua
}

if [[ ! -e $1 ]]
then
  exit
fi
json_link_file=$1
# echo "Link file: $json_link_file"
dest_file=$(get_dest_name $json_link_file)
if [[ -s $json_link_file ]]
then
  lua json_to_lua.lua $json_link_file $dest_file
  echo $dest_file
fi
mv $json_link_file $data_path/link_getter/processed

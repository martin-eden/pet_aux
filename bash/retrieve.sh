function get_tmp_name
{
  echo $data_path/tmp/$(basename $1)
}

url=$1
output_file=$2
download_file=$(get_tmp_name $output_file)

rm --force $download_file
wget \
  --no-clobber \
  --quiet \
  --read-timeout=10 \
  --output-document=$download_file $url

rm --force $output_file
mv $download_file $output_file

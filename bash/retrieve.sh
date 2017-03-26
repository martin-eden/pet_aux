local url=$1
local output_file=$2
local download_file=$($bash_path/get_tmp_name.sh $output_file)
rm --force $download_file
# echo "url: $url"
wget --no-clobber --quiet --output-document=$download_file $url
rm --force $output_file
mv $download_file $output_file

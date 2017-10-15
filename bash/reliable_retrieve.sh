url=$1
output_file=$2

if [[ -z $output_file ]]
then
  exit
fi

bash $bash_path/retrieve.sh $url $output_file

while [[ ! -s $output_file ]]
do
  sleep 1
  bash $bash_path/retrieve.sh $url $output_file
done

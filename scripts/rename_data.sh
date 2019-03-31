#!/bin/sh

# Ideally place in the same directory as the train.sh script

while getopts a:i: options; do
  case $options in
    a) anno_dir=$OPTARG;;
    i) imgs_dir=$OPTARG;;
    ?) echo "illegal option."; echo "usage: ./rename_data.sh [-a] annotation_directory [-i] img_directory"; exit 0;;
  esac
done

if [[ -z $anno_dir || ! -d $anno_dir ]]
then
  echo "annotations directory invalid or missing"
  echo "usage: ./rename_data.sh [-a] annotation_directory  [-i] img_directory"
  exit 0
elif [[ -z "$imgs_dir" || ! -d $imgs_dir ]]
then
  echo "img directory invalid or missing"
  echo "usage: ./rename_data.sh [-a] annotation_directory  [-i] img_directory"
  exit 0
fi

echo "annotations directory = $anno_dir"
echo "images directory = $imgs_dir"

read -p "Proceed with renaming? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -n "Renaming xml files.. "
  # For XML
  anno_dir="${anno_dir%/}/"

  rm "${anno_dir}train.txt"
  i=1
  sp="/-\|"
  for file in ${anno_dir}*.xml
  do
      # grab filename and extension
      filepath="${file%.*}"               # data/annotations/STAM123
      filename="${filepath#$anno_dir}"    # STAM123
      extension="${file##*.}"             # xml

      # construct new numeric filename
      numname="${filename//[!0-9]/}"
      numfullpath="${anno_dir}${numname}.${extension}"

      # replace all occurences with updated filename to match xml
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/${filename}.JPG/${numname}/" $file
      else
        sed -i "s/${filename}.JPG/${numname}/" $file
      fi

      # rename *.xml with numeric filename
      mv "${file}" "${numfullpath}" 2> /dev/null  # data/annotations/123.xml

      # add to train.txt list
      echo "${numfullpath}" >> "${anno_dir}train.txt"
      printf "\b${sp:i++%${#sp}:1}"
  done
  echo " Done."

  # For Images
  echo -n "Renaming JPG files.. "

  imgs_dir="${imgs_dir%/}/"

  for file in ${imgs_dir}*.JPG
  do
    filepath="${file%.*}"             # data/imgs/STAM123
    filename="${filepath#$imgs_dir}"  # STAM123

    mv "${file}" "${imgs_dir}${filename//[!0-9]/}" 2> /dev/null
    printf "\b${sp:i++%${#sp}:1}"
  done
  echo " Done."
fi

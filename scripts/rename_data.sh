#!/bin/sh

# Purpose: Rename images and corresponding XML filenames to only the numeric characters (including filenames in XML files)
# Output xml filenames in a 1:4 ratio to test.txt:train.txt

# Usage: ./rename_data.sh [-d <annotation_dir>] [-i <img_dir>]
rename_xml(){
  # grab filename and extension
  filepath="${1%.*}"               # data/annotations/STAM123
  filename="${filepath#$anno_dir}" # STAM123
  extension="${1##*.}"             # xml

  # construct new numeric filename
  numname="${filename//[!0-9]/}"
  numfullpath="${anno_dir}${numname}.${extension}"

  # replace all occurences with updated filename to match xml
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/${filename}.JPG/${numname}/" $1
  else
    sed -i "s/${filename}.JPG/${numname}/" $1
  fi

  # rename *.xml with numeric filename
  mv "${1}" "${numfullpath}" 2> /dev/null  # data/annotations/123.xml

  # add to train.txt list
  if [ $(($RANDOM%10)) -ge 2 ]
  then
    echo "${numname}.${extension}" >> "${anno_dir}train.txt"
  else
    echo "${numname}.${extension}" >> "${anno_dir}test.txt"
  fi
}

rename_jpg(){
  filepath="${1%.*}"                # data/imgs/STAM123
  filename="${filepath#$imgs_dir}"  # STAM123

  mv "${1}" "${imgs_dir}${filename//[!0-9]/}" 2> /dev/null
  printf "\b${sp:i++%${#sp}:1}"
}

set -m

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

RANDOM=$$

if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Renaming xml files.. "

  # For XML
  anno_dir="${anno_dir%/}/"

  rm "${anno_dir}train.txt"
  rm "${anno_dir}test.txt"

  for file in ${anno_dir}*.xml
  do
    rename_xml $file $anno_dir &
  done

  # bring background job to foreground
  while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done
  echo " Done."

  # For Images
  echo "Renaming JPG files.. "

  imgs_dir="${imgs_dir%/}/"

  for file in ${imgs_dir}*.JPG
  do
    rename_jpg $file $imgs_dir &
  done

  while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done
  echo " Done."
fi

#!/bin/sh

# Place in same dir as *.xml files you want to rename
# This replaces all <filename>*.JPG</filename> with numeric filenames
# and renames all *.xml files with corresponding numeric filenames

read -p "Are you sure this is the correct directory? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for file in *.xml
    do
        # grab filename and extension
        filename="${file%.*}"
        extension="${file##*.}"

        # construct new numeric filename
        onlynum="${file//[!0-9]/}"
        onlynumfull="${onlynum}.${extension}"

        # replace all occurences with updated filename to match xml
        sed -i '' "s/${filename}.JPG/${onlynum}.JPG/" $file

        # rename *.xml with numeric filename
        mv "${file}" "${onlynumfull}"

    done
fi

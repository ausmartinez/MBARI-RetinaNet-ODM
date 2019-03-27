#! /bin/sh
# Author: Kirk Worley
# Objective: This shell script will auto-generate a label.pbtxt file given a path to a folder containing
# 	XML files with <name></name> tags in them. If there is an existing label.pbtxt file, a prompt will
#	display asking if you wish to overwrite it.
# Usage: ./generate_labels PATH_TO_ANN
#	PATH_TO_ANN: Path to annotations folder containing XML files.

if [[ $# -eq 0 ]] ;
then
	echo "Please provide a filepath to the annotations. If the annotations are in the current folder, use '.'"
	echo "Example usage: ./generate_labels data/annotations"
	exit 0
fi

if [ -f "label.pbtxt" ]
then
	while true; do
		read -p "[LABELS]: A label.pbtxt file already exists in the current folder. Do you wish to overwrite it? (y/n): " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit 0;;
			* ) echo "Please type y or n.";;
		esac
	done
fi

if [ $1 = "." ];
then
	echo "[LABELS]: Generating label.pbxt from annotations located in current directory."
else
	echo "[LABELS]: Generating label.pbtxt from annotations located in: $1."
fi

awk '
# function to check if name exists in array already.
function smartmatch(d, r, x, y) {
  for (x in r) y[r[x]]
  return d in y
}

BEGIN {
	FS="[< >]"
	curr_id = 1
	# define entities array
	split("", entities)
}
	
/<name>/ {
	# traverses all fields in lines with a name tag.
	for(i = 1; i <= NF; i++) {
		# builds the name of the entity following the "name" tag in xml.
		if($i == "name") {
			idx = i+1
			entity_name = ""
			while($idx != "/name") {
				entity_name = (entity_name == "") ? ($idx) : (entity_name " " $idx)
				idx += 1
			}
			if(!smartmatch(entity_name, entities)) {
				entities[curr_id] = entity_name
				curr_id += 1
			} 
		}
	}
}

END {
	# generate new .pbtxt file in format.
	for(k in entities) {
		print "item {"
		print "\tid: " k
		print "\tname: " "\x27"entities[k]"\x27"
		print "}"
	}
}' $1/*.xml > label.pbtxt

#! /bin/sh
# Author: Kirk Worley
# Objective: This shell script will auto-generate a label.pbtxt file given a path to a folder containing
# 	XML files with <name></name> tags in them. If there is an existing label.pbtxt file, a prompt will
#	display asking if you wish to overwrite it.
# Usage: ./generate_labels PATH_TO_ANN
#	PATH_TO_ANN: Path to annotations folder containing XML files.
PROGNAME=$0

# Argument: Invalid flag provided.
invalid_flag() {
	echo Invalid flag. Use -h to display the usage options.
	exit 1
}

# Argument: -h
usage() {
  cat << EOF >&2
Usage: $PROGNAME [-h] [-d <dir>] [-s <dir>]

-h: Displays the usage message.
-d <dir>: Filepath to the directory containing the annotations. Example: data/annotations.
-s <dir>: Directory in which to place the label.pbtxt file. If the directory does not exist, it will be created. Default directory is current directory.
EOF
  exit 1
}

# Need arguments to run.
if [[ $# -eq 0 ]] ;
then
	invalid_flag
fi

# Parse arguments from flags using getopts.
dir="" savepath="."
while getopts d:s:h o; do
  case $o in
    (d) dir=$OPTARG;;
    (s) savepath=$OPTARG;;
	(h) usage;;
    (*) invalid_flag
  esac
done
shift "$((OPTIND - 1))"

# Does directory to save in exist?
if [ -d $savepath ]
then
	if [ $savepath = "." ]
	then
		echo "Generating label.pbtxt in current folder."
	else
		echo "Generating label.pbtxt in "$savepath"."
	fi
else
	echo $savepath "does not exist. Creating it."
	mkdir -p $savepath
fi

# Does directory to annotations exist?
if [ ! -d $dir ]
then
	echo "[ERROR]: Directory '"$dir"' does not exist. Exiting."
	exit 1
else
	echo "[LABELS]: Generating labels from XML files in "$dir"."
fi

if [ -f $savepath"/label.pbtxt" ]
then
	while true; do
		read -p "[LABELS]: A label.pbtxt file already exists in the desired folder. Do you wish to overwrite it? (y/n): " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit 0;;
			* ) echo "Please type y or n.";;
		esac
	done
fi

# Generate label.pbtxt using AWK.
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
				entity_name = (entity_name == "") ? ($idx) : (entity_name "_" $idx)
				entity_name = toupper(entity_name)
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
		print "\tname: \x27" entities[k] "\x27"
		print "}"
	}
}' $dir/*.xml > $savepath/label.pbtxt

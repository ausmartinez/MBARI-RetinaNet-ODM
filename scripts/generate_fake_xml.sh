#!/bin/sh

# generate fake xml files to test rename_xml.sh
for i in {1..5}
do
	echo "<filename>${i}abc4t.JPG</filename>" > "${i}abc4t.xml"
done

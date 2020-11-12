#!/bin/bash

BASEDIR=$(dirname $(readlink -f "$0"))
SERVICESDIR="$(dirname "$BASEDIR")/services"
SOURCESDIR="$(dirname "$BASEDIR")/sources"
OUTPUT="$(dirname "$BASEDIR")/README.adoc"
URLBASE="./"
CSVBASE="./csv"

cat > $OUTPUT <<EOF
= XList Database

This is a database of data services ready to be used on an
link:https://github.com/luids-io/xlist[xlist server].
The database has been classified according to the _class_ used in its
configuration.

WARNING: Each list provider has its own usage policy, check its website
before using it. In order to use Google Safe Browsing API, you will need
to obtain an API key.

* <<xlist-class-sblookup>>
* <<xlist-class-file>>
* <<xlist-class-dnsxl>>

In order to use the data services of the class \`file\` it is necessary to
download and keep the data synchronized. For this purpose the _xlget_ tool
must be used and this tool needs the configuration of the sources.

* <<xlget-sources>>


EOF

function genTableClass() {
	class=$1
	echo "|===" >> $OUTPUT
	echo "| ID | Name | Category | Tags | Resources | Web" >> $OUTPUT
	
	jq -s '[.[][]]' ${SERVICESDIR}/${class}/*.json | jq -s '.[][]' \
		| jq -r '{ id: .id, name: .name, category: .category, tags: (.tags // empty) |join(" ") , resources: .resources|join(" "), web: .web}' \
		| jq -r '[.id, .name, .category, .tags, .resources, .web] | @tsv' |
	while IFS=$'\t' read -r id name category tags resources web; do
		sourcefile=`grep -H "$id" ${SERVICESDIR}/${class}/*.json | cut -f1 -d ":"`
		sourcefile=`basename "$sourcefile"`
	
		echo "" >> $OUTPUT
		echo "|link:$URLBASE/services/${class}/${sourcefile}[$id]" >> $OUTPUT
		echo "|$name" >> $OUTPUT
		echo "|$category" >> $OUTPUT
		echo "|$tags" >> $OUTPUT
		echo "|$resources" >> $OUTPUT
		echo "|link:${web}[web]" >> $OUTPUT
	done
	echo "|===" >> $OUTPUT
}

function genTableSources() {	
	echo "|===" >> $OUTPUT
	echo "| ID | Update " >> $OUTPUT
	
	jq -s '[.[][]]' ${SOURCESDIR}/*.json | jq -s '.[][]' \
		| jq -r '{ id: .id, update: .update}' \
		| jq -r '[.id, .update] | @tsv' |
	while IFS=$'\t' read -r id update; do
		sourcefile=`grep "$id" ${SOURCESDIR}/*.json | cut -f1 -d ":"`
		sourcefile=`basename "$sourcefile"`
	
		echo "" >> $OUTPUT
		echo "|link:$URLBASE/sources/${sourcefile}[$id]" >> $OUTPUT
		echo "|$update" >> $OUTPUT
	done
	echo "|===" >> $OUTPUT
}

echo "[[xlist-class-sblookup]]" >> $OUTPUT
echo "== \`sblookup\` data services (Google safe browsing)" >> $OUTPUT
echo "" >> $OUTPUT
echo "link:${CSVBASE}/summary-sblookup.csv[download csv]" >> $OUTPUT
echo "" >> $OUTPUT
genTableClass "sblookup"
echo "" >> $OUTPUT


echo "[[xlist-class-file]]" >> $OUTPUT
echo "== \`file\` data services" >> $OUTPUT
echo "" >> $OUTPUT
echo "link:${CSVBASE}/summary-file.csv[download csv]" >> $OUTPUT
echo "" >> $OUTPUT
genTableClass "file"
echo "" >> $OUTPUT


echo "[[xlist-class-dnsxl]]" >> $OUTPUT
echo "== \`dnsxl\` data services" >> $OUTPUT
echo "" >> $OUTPUT
echo "link:${CSVBASE}/summary-dnsxl.csv[download csv]" >> $OUTPUT
echo "" >> $OUTPUT
genTableClass "dnsxl"
echo "" >> $OUTPUT


echo "[[xlget-sources]]" >> $OUTPUT
echo "== \`xlget\` sources" >> $OUTPUT
echo "" >> $OUTPUT
genTableSources
echo "" >> $OUTPUT

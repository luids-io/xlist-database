#!/bin/bash

SRCDIR=$(dirname $(readlink -f "$0"))
DBDIR="$(dirname "$SRCDIR")/database"
OUTPUT="$(dirname "$SRCDIR")/README.adoc"
URLBASE="./database"
CSVBASE="./csv"

cat > $OUTPUT <<EOF
= XList Database

This is a database of data sources ready to be used on an
link:https://github.com/luids-io/xlist[xlist server].
The database has been classified according to the _class_ used in its
configuration.

WARNING: Each list provider has its own usage policy, check its website
before using it. In order to use Google Safe Browsing API, you will need
to obtain an API key.

* <<xlist-class-sblookup>>
* <<xlist-class-dnsxl>>
* <<xlist-class-file>>

In order to use the data sources of the class \`file\` it is necessary to
download and keep the data synchronized. For this purpose the _xlget_ tool must
be used and this tool needs the configuration of the feeds.

* <<xlget-feeds>>


EOF

function genTableClass() {
	class=$1
	echo "== \`${class}\` data sources" >> $OUTPUT
	echo "" >> $OUTPUT
	echo "link:${CSVBASE}/summary-${class}.csv[download csv]" >> $OUTPUT
	echo "" >> $OUTPUT
	
	echo "|===" >> $OUTPUT
	echo "| ID | Name | Category | Tags | Resources | Web" >> $OUTPUT
	
	jq -s '[.[][]]' ${DBDIR}/${class}/*.json | jq -s '.[][]' \
		| jq -r '{ id: .id, name: .name, category: .category, tags: (.tags // empty) |join(" ") , resources: .resources|join(" "), web: .web}' \
		| jq -r '[.id, .name, .category, .tags, .resources, .web] | @tsv' |
	while IFS=$'\t' read -r id name category tags resources web; do
		sourcefile=`grep -H "$id" ${DBDIR}/${class}/*.json | cut -f1 -d ":"`
		sourcefile=`basename "$sourcefile"`
	
		echo "" >> $OUTPUT
		echo "|link:$URLBASE/${class}/${sourcefile}[$id]" >> $OUTPUT
		echo "|$name" >> $OUTPUT
		echo "|$category" >> $OUTPUT
		echo "|$tags" >> $OUTPUT
		echo "|$resources" >> $OUTPUT
		echo "|link:${web}[web]" >> $OUTPUT
	done
	echo "|===" >> $OUTPUT
}

function genTableFeeds() {
	echo "== \`xlget\` feeds" >> $OUTPUT
	echo "" >> $OUTPUT
	
	echo "|===" >> $OUTPUT
	echo "| ID | Update " >> $OUTPUT
	
	jq -s '[.[][]]' ${DBDIR}/feeds/*.json | jq -s '.[][]' \
		| jq -r '{ id: .id, update: .update}' \
		| jq -r '[.id, .update] | @tsv' |
	while IFS=$'\t' read -r id update; do
		sourcefile=`grep "$id" ${DBDIR}/feeds/*.json | cut -f1 -d ":"`
		sourcefile=`basename "$sourcefile"`
	
		echo "" >> $OUTPUT
		echo "|link:$URLBASE/feeds/${sourcefile}[$id]" >> $OUTPUT
		echo "|$update" >> $OUTPUT
	done
	echo "|===" >> $OUTPUT
}

echo "[[xlist-class-sblookup]]" >> $OUTPUT
genTableClass "sblookup"

echo "" >> $OUTPUT

echo "[[xlist-class-dnsxl]]" >> $OUTPUT
genTableClass "dnsxl"

echo "" >> $OUTPUT


echo "[[xlist-class-file]]" >> $OUTPUT
genTableClass "file"

echo "" >> $OUTPUT

echo "[[xlget-feeds]]" >> $OUTPUT
genTableFeeds



#!/bin/bash

# gets script dir
BASEDIR=$(dirname $(readlink -f "$0"))
SERVICESDIR="$(dirname "$BASEDIR")/services"
SOURCESDIR="$(dirname "$BASEDIR")/sources"
CSVDIR="$(dirname "$BASEDIR")/csv"

## create file csv
CSVFILE=${CSVDIR}/summary-file.csv
echo '"id","name","deprecated","removed","category","tags","resources","web"' > $CSVFILE
jq -s '[.[][]]' ${SERVICESDIR}/file/*.json | jq -s '.[][]' \
	| jq -r '{ id: .id, name: .name, deprecated: .deprecated, removed: .removed, category: .category, tags: (.tags // empty) |join(";") , resources: .resources|join(";"), web: .web}' \
	| jq -r '[.id, .name, .deprecated, .removed, .category, .tags, .resources, .web] | @csv' >> $CSVFILE


## create dnsxl csv
CSVFILE=${CSVDIR}/summary-dnsxl.csv
echo '"id","name","deprecated","removed","category","tags","resources","web"' > $CSVFILE
jq -s '[.[][]]' ${SERVICESDIR}/dnsxl/*.json | jq -s '.[][]' \
	| jq -r '{ id: .id, name: .name, deprecated: .deprecated, removed: .removed, category: .category, tags: (.tags // empty) |join(";") , resources: .resources|join(";"), web: .web}' \
	| jq -r '[.id, .name, .deprecated, .removed, .category, .tags, .resources, .web] | @csv' >> $CSVFILE

## create sblookup csv
CSVFILE=${CSVDIR}/summary-sblookup.csv
echo '"id","name","deprecated","removed","category","tags","resources","web"' > $CSVFILE
jq -s '[.[][]]' ${SERVICESDIR}/sblookup/*.json | jq -s '.[][]' \
	| jq -r '{ id: .id, name: .name, deprecated: .deprecated, removed: .removed, category: .category, tags: (.tags // empty) |join(";") , resources: .resources|join(";"), web: .web}' \
	| jq -r '[.id, .name, .deprecated, .removed, .category, .tags, .resources, .web] | @csv' >> $CSVFILE


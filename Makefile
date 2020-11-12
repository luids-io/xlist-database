# Makefile for building database

# Used to populate version in binaries
VERSION=$(shell git describe --match 'v[0-9]*' --dirty='.m' --always)
REVISION=$(shell git rev-parse HEAD)$(shell if ! git diff --no-ext-diff --quiet --exit-code; then echo .m; fi)
DATEBUILD=$(shell date +%FT%T%z)

# Compilation opts
# Print output
WHALE = "+"

.PHONY: all database
all: database

database:
	@echo "$(WHALE) $@"
	scripts/update_csv.sh
	scripts/update_readme.sh
	asciidoctor README.adoc

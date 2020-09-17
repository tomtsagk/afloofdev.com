
### Variables ###

#
# build directory
#
OUT=_site

#
# directories to put files in
#
DIRECTORIES_DST=${OUT} ${OUT}/pages ${OUT}/images ${OUT}/files

#
# raw files that are to be copied as-is on the same
# path as the source file
#
RAW_FILES_SRC=LICENSE style.css favicon.ico logo.png robots.txt $(wildcard images/*) $(wildcard files/*)
RAW_FILES_DST=$(RAW_FILES_SRC:%=${OUT}/%)

#
# page files, to be parsed from json
#
PAGES_SRC_JSON=$(wildcard index.json pages/*.json)
PAGES_OUT_JSON=$(PAGES_SRC_JSON:%.json=${OUT}/%.html)
PAGES_SRC_MD=$(PAGES_SRC_JSON:%.json=%.md)

#
# sitemap
#
SITEMAP_DST=${OUT}/sitemap.xml

#
# The template all pages use
#
TEMPLATE=template.md

### Rules ###

#
# build the whole site
#
all: ${DIRECTORIES_DST} ${RAW_FILES_DST} ${PAGES_OUT_JSON} ${SITEMAP_DST} ${INDEX_DST} # ${INDEX_DST}

#
# files that have no other rule, are copied to destination
#
${OUT}/%: %
	cp $^ $@

#
# build output directories
#
${DIRECTORIES_DST}:
	mkdir -p $@

#
# build pages from json
#
${OUT}/%.html: %.json ${TEMPLATE}
	./generate_page.sh $@ $<

#
# sitemap generation
#
${SITEMAP_DST}: ${PAGES_SRC_JSON}
	cat sitemap.xml.in > $@
	echo "<lastmod>$(shell date +%Y-%m-%d)</lastmod></url>" >> $@
	echo "$(foreach var,${PAGES_OUT_JSON},<url><loc>http://darkdimension.org/${var}</loc><lastmod>$(shell date +%Y-%m-%d)</lastmod></url>)" >> $@


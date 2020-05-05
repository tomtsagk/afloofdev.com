
OUT=_site

INDEX_DST=${OUT}/index.html
POSTS=$(wildcard posts/*.md)
POSTS_OBJ=$(subst .md,.mdobj,${POSTS})

#
# logo favicon style and license
#
LOGO_NAME=logo.png
LOGO_SRC=${LOGO_NAME}
LOGO_DST=${OUT}/${LOGO_NAME}

FAVICON_NAME=favicon.ico
FAVICON_SRC=${FAVICON_NAME}
FAVICON_DST=${OUT}/${FAVICON_NAME}

STYLE_NAME=style.css
STYLE_SRC=${STYLE_NAME}
STYLE_DST=${OUT}/${STYLE_NAME}

LICENSE_NAME=LICENSE
LICENSE_SRC=${LICENSE_NAME}
LICENSE_DST=${OUT}/${LICENSE_NAME}

#
# pages
#
PAGES_SRC=$(wildcard pages/*.md)
PAGES_OUT=$(subst .md,.html,$(subst pages,${OUT}/pages,${PAGES_SRC}))

#
# images
#
IMAGES_SRC=$(wildcard images/*)
IMAGES_DST=$(subst images,${OUT}/images,${IMAGES_SRC})

TEMPLATE=template.md

# build the whole site
all: ${LOGO_DST} ${FAVICON_DST} ${STYLE_DST} ${PAGES_OUT} ${LICENSE_DST} ${IMAGES_DST}# ${INDEX_DST}

# build output directory
${OUT}:
	mkdir -p ${OUT}

#
# build logo, favicon and sstyle
#
${LOGO_DST}: ${LOGO_SRC}
	cp ${LOGO_SRC} ${LOGO_DST}

${FAVICON_DST}: ${FAVICON_SRC}
	cp ${FAVICON_SRC} ${FAVICON_DST}

${STYLE_DST}: ${STYLE_SRC}
	cp ${STYLE_SRC} ${STYLE_DST}

${LICENSE_DST}: ${LICENSE_SRC}
	cp ${LICENSE_SRC} ${LICENSE_DST}

# build pages
${OUT}/pages/%.html: pages/%.md ${TEMPLATE}
	mkdir -p ${OUT}/pages
	cat ${TEMPLATE} | sed "s/@STYLE_PREFIX@/..\//g" | sed "s/@ROOT@/..\//g" | sed "/@CONTENT@/Q" | markdown > $@
	cat $< | sed "s/@DIR_IMAGES@/..\/images\//g" | markdown >> $@
	cat ${TEMPLATE} | sed "1,/@CONTENT@/d" | markdown >> $@

# build images
${OUT}/images/%: images/%
	mkdir -p ${OUT}/images
	cp $^ $@

# build index and history
#${INDEX_DST}: ${POSTS_OBJ} 
#	cat ${TEMPLATE} | sed "s/@STYLE_PREFIX@//g" | sed "s/@ROOT@//g" | sed "/@CONTENT@/Q" | markdown > $@
#	cat `echo $^ | sed "s/ /\n/g" | sort -r` >> $@
#	cat ${TEMPLATE} | sed "1,/@CONTENT@/d" | markdown >> $@

#%.mdobj: %.md
#	#cat $^ | markdown > $@
#	#bash generate2

#	# each X number of posts, make a page, starting from index, and moving to history
#	cd posts
#	PAGE_NUMBER=0
#	POST_NUMBER=0
#	for i in `ls -r *`; do
#		date="${i:0:4}${i:4:2}${i:6:2} ${i:8:2}:${i:10:2}"
#		date=$(date --date="$date" +"%Y.%m.%d - %a %H:%M")
#		post="$(cat $i)"
#		post="$post\n\n$date\n\n---\n"
#
#		# currently, make a new page every 5 posts
#		POST_NUMBER=$(($POST_NUMBER+1))
#		if [ $POST_NUMBER -gt 5 ]; then
#			PAGE_NUMBER=$(($PAGE_NUMBER+1))
#			POST_NUMBER=1
#		fi
#		CONTENTS[PAGE_NUMBER]=${CONTENTS[PAGE_NUMBER]}$post
#	done
#	cd ..

## print all pages with posts
#i=0
#while [ ! -z "${CONTENTS[i]}" ]; do
#
#	# there's another page, so make a "next" link at the end
#	if [ ! -z "${CONTENTS[i+1]}" ]; then
#		CONTENTS[i]=${CONTENTS[i]}"<a href='history_$((i+1)).html'>next</a>
#
#---
#
#"
#	fi
#
#	# first page is index, the rest are history
#	if [ "$i" -eq 0 ]; then
#		gen_page "${CONTENTS[i]}" _site/index.html
#	# not first page, so put a "previous" link in the beginning
#	else
#		if [ "$i" -eq 1 ]; then
#			PAGE=index
#		else
#			PAGE=history_$((i-1))
#		fi
#		CONTENTS[i]="<a href='$PAGE.html'>previous</a>
#
#---
#
#${CONTENTS[i]}
#"
#
#		# generate page
#		gen_page "${CONTENTS[i]}" _site/history_$i.html
#	fi
#	((i++))
#done

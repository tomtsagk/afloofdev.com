
### Variables

#
# build directory
#
OUT=_site

#
# directories to put files in
#
DIRECTORIES_DST=${OUT} ${OUT}/pages ${OUT}/images ${OUT}/files

#
# Index files
#
#INDEX_DST=${OUT}/index.html
#POSTS=$(wildcard posts/*.md)
#POSTS_OBJ=$(subst .md,.mdobj,${POSTS})

#
# raw files that are to be copied as-is on the same
# path as the source file
#
RAW_FILES_SRC=LICENSE style.css favicon.ico logo.png sitemap.xml robots.txt $(wildcard images/*) $(wildcard files/*)
RAW_FILES_DST=$(RAW_FILES_SRC:%=${OUT}/%)

#
# page files
#
PAGES_SRC=$(wildcard pages/*.md)
PAGES_OBJ=$(PAGES_SRC:.md=.o)
PAGES_OUT=$(PAGES_OBJ:%.o=${OUT}/%.html)

#
# The template all pages use
#
TEMPLATE=template.md

### Rules ###

#
# build the whole site
#
all: ${DIRECTORIES_DST} ${PAGES_OUT} ${RAW_FILES_DST}# ${INDEX_DST}

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
# how to compile all markdown files to "object" files
#
%.o: %.md ${TEMPLATE}
	cat ${TEMPLATE} | sed "s/@ROOT@/../g" | sed "/@CONTENT@/Q" | markdown > $@
	cat $< | sed "s/@ROOT@/../g" | markdown >> $@
	cat ${TEMPLATE} | sed "s/@ROOT@/../g" | sed "1,/@CONTENT@/d" | markdown >> $@

#
# build pages based on their "object" files
#
${OUT}/pages/%.html: pages/%.o
	cp $< $@

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

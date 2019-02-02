#!/bin/sh

# Clean site and make sure folder exists
rm -rf _site
mkdir -p _site

# get data
cp logo.png _site
cp favicon.ico _site
cp style.css _site

# Get template
TEMPLATE=$(cat template.md)

# replace contents with first argument, parse with markdown,
# and paste on second argument
gen_page() {
	echo -e "${TEMPLATE/@CONTENT@/$1}" > temp.md
	markdown temp.md > $2
}

# get each post and combine in $CONTENTS
cd posts
for i in `ls -r *`; do
	date="${i:0:4}${i:4:2}${i:6:2} ${i:8:2}:${i:10:2}"
	date=$(date --date="$date" +"%Y.%m.%d - %a %H:%M")
	post="$(cat $i)"
	post="$post

$date

---

"
	CONTENTS=$CONTENTS$post
done
cd ..

# generate index page
gen_page "$CONTENTS" _site/index.html

# generate pages
cd pages
for i in *; do
	PAGE=$(cat $i)"

---

"
	cd ..
	gen_page "$PAGE" _site/${i/.md/.html}
	cd pages
done
cd ..

# copy license
cp LICENSE _site/LICENSE

# remove temp files
rm temp.md

# if destination exists, move files there
# this is made in such a way to reduce site downtime when updating
if [ ! -z "$1" ]
then
	mv $1 _site_temp
	mv _site $1
	rm -rf _site_temp
fi

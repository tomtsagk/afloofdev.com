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

# each X number of posts, make a page, starting from index, and moving to history
cd posts
PAGE_NUMBER=0
POST_NUMBER=0
for i in `ls -r *`; do
	date="${i:0:4}${i:4:2}${i:6:2} ${i:8:2}:${i:10:2}"
	date=$(date --date="$date" +"%Y.%m.%d - %a %H:%M")
	post="$(cat $i)"
	post="$post

$date

---

"

	# currently, make a new page every 5 posts
	POST_NUMBER=$(($POST_NUMBER+1))
	if [ $POST_NUMBER -gt 5 ]; then
		PAGE_NUMBER=$(($PAGE_NUMBER+1))
		POST_NUMBER=1
	fi
	CONTENTS[PAGE_NUMBER]=${CONTENTS[PAGE_NUMBER]}$post
done
cd ..

# print all pages with posts
i=0
while [ ! -z "${CONTENTS[i]}" ]; do

	# there's another page, so make a "next" link at the end
	if [ ! -z "${CONTENTS[i+1]}" ]; then
		CONTENTS[i]=${CONTENTS[i]}"<a href='history_$((i+1)).html'>next</a>

---

"
	fi

	# first page is index, the rest are history
	if [ "$i" -eq 0 ]; then
		gen_page "${CONTENTS[i]}" _site/index.html
	# not first page, so put a "previous" link in the beginning
	else
		if [ "$i" -eq 1 ]; then
			PAGE=index
		else
			PAGE=history_$((i-1))
		fi
		CONTENTS[i]="<a href='$PAGE.html'>previous</a>

---

${CONTENTS[i]}
"

		# generate page
		gen_page "${CONTENTS[i]}" _site/history_$i.html
	fi
	((i++))
done

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

#!/bin/sh

# Get template
TEMPLATE=$(cat template.md)

## replace contents with first argument, parse with markdown,
## and paste on second argument
gen_page() {
	echo -e "${TEMPLATE/@CONTENT@/$1}" | sed "s/@STYLE_PREFIX@//g" | sed "s/@ROOT@//g" | markdown > $2
}

# each X number of posts, make a page, starting from index, and moving to history
cd posts
PAGE_NUMBER=0
POST_NUMBER=0
POSTS_TOTAL=`ls | wc -l`
POSTS_CURRENT=0
for i in `ls -r *`; do
	date="${i:0:4}${i:4:2}${i:6:2} ${i:8:2}:${i:10:2}"
	date=$(date --date="$date" +"%Y.%m.%d - %a %H:%M")
	post="$(cat $i)"
	post="$post\n\n$date\n\n"

	# control lines so the last post has no horizontal line
	if [ $POSTS_CURRENT -lt 4 -o $POSTS_CURRENT -eq $((POSTS_TOTAL - 1)) ]; then
		post="$post---\n\n"
		POSTS_CURRENT=$(( $POSTS_CURRENT + 1))
	else
		POSTS_CURRENT=0
	fi

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
		CONTENTS[i]=${CONTENTS[i]}"---\n\n<a href='history_$((i+1)).html'>next</a>\n\n"
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
		CONTENTS[i]="<a href='$PAGE.html'>previous</a>\n\n---\n\n${CONTENTS[i]}\n"

		# generate page
		gen_page "${CONTENTS[i]}" _site/history_$i.html
	fi
	((i++))
done

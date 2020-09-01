#!/bin/sh

# Get template
TEMPLATE=$(cat template.md)

## replace contents with first argument, parse with markdown,
## and paste on second argument
gen_page() {
	echo -e "${TEMPLATE/@CONTENT@/$1}" | sed "s/@STYLE_PREFIX@//g" | sed "s/@ROOT@/./g" |\
		sed "s/@TITLE@/$3/g" | markdown > $2
}

# each X number of posts, make a page, starting from index, and moving to history
cd posts
PAGE_NUMBER=0
POST_NUMBER=0
POSTS_TOTAL=`ls | wc -l`
POSTS_CURRENT=0
POSTS_CURRENT_TOTAL=0
for i in `ls -r *`; do
	date="${i:0:4}${i:4:2}${i:6:2} ${i:8:2}:${i:10:2}"
	date=$(date --date="$date" +"%Y.%m.%d - %a %H:%M")
	post="$(cat $i)"
	post="$post\n\n$date\n\n"

	# control lines so the last post has no horizontal line
	if [ $POSTS_CURRENT -eq 4 -o $POSTS_CURRENT_TOTAL -eq $((POSTS_TOTAL - 1)) ]; then
		POSTS_CURRENT=0
	else
		post="$post---\n\n"
		POSTS_CURRENT=$(( $POSTS_CURRENT + 1))
	fi
	POSTS_CURRENT_TOTAL=$(( $POSTS_CURRENT_TOTAL + 1))

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
pagesTotal=${#CONTENTS[@]}
while [ ! -z "${CONTENTS[i]}" ]; do

	# find the page index to display
	pageIndex=$(($i +1))

	# Not first page, so prepare "previous" functionality
	if [ "$i" -gt 0 ]; then

		# check previous page name
		if [ "$i" -eq 1 ]; then
			PAGE=index
		else
			PAGE=history_$((i-1))
		fi
		previousButton="<a class=\"menu\" href='$PAGE.html'><</a>"
	else
		previousButton=""
	fi

	# Next page button
	if [ ! -z "${CONTENTS[i+1]}" ]; then
		nextButton="<a class=\"menu\" href='history_$((i+1)).html'>></a>"
	else
		nextButton=""
	fi

	# the final text: <previousButton> Page X / Y <nextButton>
	pageButton="$previousButton Page $pageIndex / $pagesTotal $nextButton"

	# Always show page index at the bottom of the page
	CONTENTS[i]=${CONTENTS[i]}"---\n\n$pageButton\n\n"
	#CONTENTS[i]="$pageButton\n\n---\n\n${CONTENTS[i]}\n"

	# first page is index, the rest are history
	if [ "$i" -eq 0 ]; then
		gen_page "${CONTENTS[i]}" _site/index.html ": Home"
	# not first page, so put a "previous" link in the beginning
	else
		# generate page
		gen_page "${CONTENTS[i]}" _site/history_$i.html ": History $i"
	fi
	((i++))
done

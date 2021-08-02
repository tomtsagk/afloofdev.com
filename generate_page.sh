#!/bin/sh

ad="
<iframe src=\"https://viewm.moonicorn.network/#%7B%22options%22%3A%7B%22publisherAddr%22%3A%220x4C191717BA8F3b5Ee19e5B4F6975023529E5984C%22%2C%22whitelistedTokens%22%3A%5B%220x6B175474E89094C44Da98b954EedeAC495271d0F%22%5D%2C%22whitelistedType%22%3A%22legacy_300x250%22%2C%22randomize%22%3Atrue%2C%22targeting%22%3A%5B%5D%2C%22width%22%3A%22300%22%2C%22height%22%3A%22250%22%2C%22minPerImpression%22%3A%220%22%2C%22fallbackUnit%22%3A%22QmX2SLnCVEB1c8kY41tM4cLPtXi3h5XFMuNi4Lt1bfvjyf%22%2C%22marketSlot%22%3A%22QmNN1UY4iNekLWjDVodtvZfSKgWCnf9UU7PXsDQRHDEAdG%22%7D%7D\"
	width=\"300\"
	height=\"250\"
	scrolling=\"no\"
	frameborder=\"0\"
	style=\"border: 0;\"
	onload=\"window.addEventListener('message', function(ev) {
		if (ev.data.hasOwnProperty('adexHeight') && ('https://viewm.moonicorn.network' === ev.origin)) {
			for (let f of document.getElementsByTagName('iframe')) {
				if (f.contentWindow === ev.source) {
					f.height = ev.data.adexHeight;
				}
			}
		}
	}, false)\"
></iframe>"

#
# source is the json file that describes a page
# destination is the final html file
#
target_src=$2
target_dst=$1

#
# Parse data for destination file
#
title=$(jq -r .title $target_src)
description=$(jq -r .description $target_src)
contentType=$(jq -r .contentType $target_src)

#
# get root location based on the filename
#
root="."
IFS='/'
read -a parentDir <<< "$target_dst"
unset IFS
i=2
while [[ $i -lt ${#parentDir[@]} ]]; do
	root=$root"\/.."
	i=$(( $i + 1 ))
done

#
# template for all pages
#
TEMPLATE=$(cat md_files/template.md)

#
# static content files
#
static_content_files=()
static_content_file=$(jq -r .content_static $target_src)
if [[ "$static_content_file" != "null" ]]; then
	static_content_files+=($static_content_file)
fi

#
# collect all content files in an array
#
content_files=()
content_file=$(jq -r .content[0] $target_src)
i=1
while [[ "$content_file" != "null" ]]; do
	content_files+=($content_file)
	content_file=$(jq -r .content[$i] $target_src)
	i=$(($i +1))
done

#
# reverse order so newer ones come first
#
IFS=$'\n' content_files=($(sort -r <<<"${content_files[*]}"))
unset IFS

#
# print pages
#
i=0
pageCount=0
while [[ $i -lt ${#content_files[@]} ]]; do

	hasShownAd=0
	content=""

	if [[ $contentType == "grid" ]]
	then
		# parent div
		content=$(echo -e "$content <div class=\"content-grid\">")
	fi

	#
	# print all static content to a variable
	#
	for j in "${static_content_files[@]}"; do
		content=$(echo -e "$content $(cat $j | sed s/0/$pageCount/ | markdown)<hr style='display:none;'>")
	done

	#
	# print all content to a variable, 5 posts per page
	#
	j=0
	while [[ $i -lt ${#content_files[@]} ]] && [[ $j -lt 5 ]]; do

		# add an ad before the third post on a page with multiple posts
		if [[ $j -eq 2 && $hasShownAd == 0 ]]; then
			hasShownAd=1
			content=$(echo -e "$content$ad")
		fi

		#
		# get filename, to parse date
		#
		filename=""
		IFS='/'
		read -a strarr <<< "${content_files[$i]}"
		unset IFS
		filename=${strarr[-1]}

		#
		# parse date - if file contains it
		#
		if [[ "$filename" =~ ^[0-9]{12} ]]
		then
			date="${filename:0:4}${filename:4:2}${filename:6:2} ${filename:8:2}:${filename:10:2}"
			date="<p class=\"center-aligned\">"$(date --date="$date" +"%Y.%m.%d - %a %H:%M")"</p>"
		else
			date=""
		fi

		if [[ $i -ne 0 ]]; then
			content=$(echo -e "$content<hr class='hidden'>")
		fi

		#
		# apply contents
		#
		# grid is showing small tiles, 3 per row
		# input is json data
		#
		if [[ $contentType == "grid" ]]
		then
			#content=$(echo -e "$content <div class=\"content-grid\">$(cat ${content_files[$i]} | markdown) $date</div>")
			gameName=$(jq -r .name ${content_files[$i]})
			#gameDescription=$(echo -e $(jq -r .description ${content_files[$i]} | markdown))
			gameDescriptionShort=$(echo -e $(jq -r .description_short ${content_files[$i]}))
			gameCover=$(jq -r .cover ${content_files[$i]})
			gamePrice=$(jq -r .price ${content_files[$i]})

			# prepare tile
			content=$(echo -e "$content <div class=\"content-grid-tile\">")

			# name and description
			#content=$(echo -e "$content $gameDescription")
			content=$(echo -e "$content <img src=\"..$gameCover\">")
			content=$(echo -e "$content <h4>$gameName</h4>\n")
			content=$(echo -e "$content <p class=\"content-grid-tile-description\">$gameDescriptionShort</p>")
			content=$(echo -e "$content <p class=\"content-grid-tile-price\">$gamePrice</p>")

#			# links
#			gameLinkName=$(jq -r .links[0].name ${content_files[$i]})
#			gameLinkTarget=$(jq -r .links[0].link ${content_files[$i]})
#			linkNum=1
#			while [[ "$gameLinkName" != "null" ]]; do
#				content=$(echo -e "$content $gameLinkName")
#				content=$(echo -e "$content $gameLinkTarget")
#				gameLinkName=$(jq -r .links[$linkNum].name ${content_files[$i]})
#				gameLinkTarget=$(jq -r .links[$linkNum].link ${content_files[$i]})
#				linkNum=$(($linkNum +1))
#			done
#
#			# screenshots
#			gameScreenshot=$(jq -r .screenshots[0] ${content_files[$i]})
#			screenshotNum=1
#			while [[ "$gameScreenshot" != "null" ]]; do
#				content=$(echo -e "$content $gameScreenshot")
#				gameScreenshot=$(jq -r .screenshots[$screenshotNum] ${content_files[$i]})
#				screenshotNum=$(($screenshotNum +1))
#			done

			# end tile
			content=$(echo -e "$content $date</div>")

		# normal markdown content
		else
			localContent=$(cat ${content_files[$i]})
			if [[ "$localContent" == *"@DD-AD@"* && $hasShownAd == 0 ]]; then
				echo "show ad"
				hasShownAd=1
				localContent=$(echo -e "${localContent/@DD-AD@/$ad}")
			fi
			localContent=$(echo -e "${localContent//@DD-AD@/}")
			if [[ $contentType != "html" ]]; then
				localContent=$(echo -e "${localContent}" | markdown)
			fi
			content=$(echo -e "$content <div class=\"content\">$localContent $date</div>")
		fi

		i=$(( $i + 1))
		j=$(( $j + 1 ))

	done

	if [[ $contentType == "grid" ]]
	then
		# parent div close
		content=$(echo -e "$content </div>")
	fi

	#
	# for pages after the first, add `-$i` to its name
	#
	IFS='.'
	read -a strarr <<< "$target_dst"
	unset IFS
	filename=${strarr[-2]}

	if [[ $pageCount -gt 0 ]]; then
		filename=$filename-$pageCount.${strarr[-1]}
	else
		filename=$target_dst
	fi

	#
	# page buttons
	#
	pageIndex=$(( $pageCount + 1 ))

	#
	# Not first page, so prepare "previous" functionality
	#
	if [ "$pageCount" -gt 0 ]; then

		# check previous page name
		if [ "$pageCount" -eq 1 ]; then
			if [[ "$target_dst" == "_site/index.html" ]]; then
				PAGE="."
			else
				PAGE=$target_dst
			fi
		else
			PAGE=${strarr[-2]}-$(( $pageCount -1 )).${strarr[-1]}
		fi
		IFS='/'
		read -a filearr <<< "$PAGE"
		unset IFS
		previousButton="<a class=\"menu\" href='${filearr[-1]}'><b><</b></a>"
	else
		previousButton=""
	fi

	#
	# Next page button
	#
	if [ ! -z "${content_files[i]}" ]; then
		PAGE=${strarr[-2]}-$(( $pageCount +1 )).${strarr[-1]}
		IFS='/'
		read -a filearr <<< "$PAGE"
		unset IFS
		nextButton="<a class=\"menu\" href='${filearr[-1]}'><b>></b></a>"
	else
		nextButton=""
	fi

	#
	# the final text: <previousButton> 0 1 2 .. N <nextButton>
	#
	pageButton="<p class=\"center-aligned\">$previousButton "
	for (( j=0; j<=$(( (${#content_files[@]}-1) / 5 )); j++))
	do

		if [ $j -eq 0 ]
		then
			PAGE=${strarr[-2]}.${strarr[-1]}
		else
			PAGE=${strarr[-2]}-$j.${strarr[-1]}
		fi
		IFS='/'
		read -a filearr <<< "$PAGE"
		unset IFS

		if [ $j -eq 0 ]
		then
			if [ "$PAGE" == "_site/index.html" ]
			then
				destination="./"
			else
				destination=${filearr[-1]}
			fi
		else
			destination=${filearr[-1]}
		fi

		if [ $pageCount -eq $j ]
		then
			pageButton=$pageButton" <a class=\"menu-selected\" href='$destination'><b>"$j"</b></a>"
		else
			pageButton=$pageButton" <a class=\"menu\" href='$destination'><b>"$j"</b></a>"
		fi
	done
	pageButton="<hr style='display:none'>$pageButton $nextButton</p>"
	if [ ${#content_files[@]} -le 5 ]
	then
		pageButton=""
	fi

	#
	# add buttons on each page
	#
	content=$(echo -e "$content $pageButton")

	#
	# prepare page specific details
	#
	if [ "$pageCount" -gt 0 ]; then
		pageTitle="$title #$pageCount"
	else
		pageTitle=$title
	fi

	#
	# print variable to destination file
	#
	echo -e "${TEMPLATE/@CONTENT@/${content}}" | sed "s/@STYLE_PREFIX@//g" | sed "s/@ROOT@/$root/g" |\
		sed "s/@TITLE@/$pageTitle/g" | sed "s/@DESCRIPTION@/$description/g" > $filename

	pageCount=$(( $pageCount + 1 ))

done

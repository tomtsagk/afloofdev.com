#!/bin/sh

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
TEMPLATE=$(cat template.md)

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

	content=""

	#
	# print all static content to a variable
	#
	for j in "${static_content_files[@]}"; do
		content=$(echo -e "$content $(cat $j | sed s/0/$pageCount/ | markdown)<hr>")
	done

	#
	# print all content to a variable, 5 posts per page
	#
	j=0
	while [[ $i -lt ${#content_files[@]} ]] && [[ $j -lt 5 ]]; do

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
		content=$(echo -e "$content <div class=\"content\">$(cat ${content_files[$i]} | markdown) $date</div>")

		i=$(( $i + 1))
		j=$(( $j + 1 ))

	done

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
	if [ ! -z "${content_files[i+1]}" ]; then
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
	pageButton="<hr>$pageButton $nextButton</p>"
	if [ ${#content_files[@]} -le 5 ]
	then
		pageButton=""
	fi

	#
	# add buttons on each page
	#
	content=$(echo -e "$content $pageButton")

	#
	# print variable to destination file
	#
	echo -e "${TEMPLATE/@CONTENT@/${content}}" | sed "s/@STYLE_PREFIX@//g" | sed "s/@ROOT@/$root/g" |\
		sed "s/@TITLE@/$title/g" | sed "s/@DESCRIPTION@/$description/g" | markdown > $filename

	pageCount=$(( $pageCount + 1 ))

done

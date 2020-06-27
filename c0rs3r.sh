#!/bin/bash

start_time=$(date +%s)

# User domain input
site=$1;
url=${site#*.}

if [ $# -eq 0 ]
  then
  	echo ""
    echo "No URL Specified."
    echo "Usage: bash $0 https://www.example.com"
    echo ""
    exit
else
	clear
fi

# Print Details
echo "Url: $site"
echo ""

# Headers
O1="Origin: https://evil.com"		# Access-Control-Allow-Origin: https://evil.com
O2="Origin: null"					# Access-Control-Allow-Origin: null
O3="Origin:" 						# Access-Control-Allow-Origin: null
O4="Origin: evil.$url"				# Access-Control-Allow-Origin: evil.example.com
O5="Origin: https://not$url"		# Access-Control-Allow-Origin: https://notexample.com
O6="Origin: $site.evil.com"			# Access-Control-Allow-Origin: https://example.com.evil.com
O7="Origin: $site$payload.evil.com"	# Access-Control-Allow-Origin: https://example.com!.evil.com

if [[ $(curl -s -I -H "$O1" -X GET $site | grep "https://evil.com") ]]; then
	echo "Found: [$site] => [$O1]"
	echo ""

elif [[ $(curl -s -I -H "$O2" -X GET $site | grep "Access-Control-Allow-Origin: null") ]]; then
	echo "Found: [$site] => [$O2]"
	echo ""

elif [[ $(curl -s -I -H "$O3" -X GET $site | grep "Access-Control-Allow-Origin: null") ]]; then
	echo "Found: [$site] => [$O3]"
	echo ""

elif [[ $(curl -s -I -H "$O4" -X GET $site | grep "Access-Control-Allow-Origin: evil.$url") ]]; then
	echo "Found: [$site] => [$O4]"
	echo ""

elif [[ $(curl -s -I -H "$O5" -X GET $site | grep "Access-Control-Allow-Origin: https://not$url.com") ]]; then
	echo "Found: [$site] => [$O5]"
	echo ""

elif [[ $(curl -s -I -H "$O6" -X GET $site | grep "Access-Control-Allow-Origin: $site.evil.com") ]]; then
	echo "Found: [$site] => [$O6]"
	echo ""

elif [[ $(payloads=("!" "(" ")" "'" ";" "=" "^" "{" "}" "|" "~" '"' '`' "," "%60" "%0b"); for payload in ${payloads[*]}; do curl -s -I -H "$O7" -X GET "$site"; done | grep "$site$payload.evil.com") ]]; then
	echo "Found: [$site] => [$O7]"
	echo ""

else
	echo "No CORS Misconfigurations found."
	echo ""

fi

end_time=$(date +%s)
echo "Elapsed Time: $(($end_time - $start_time)) Seconds"
echo "Exit Code: $?"
echo ""
#!/bin/bash
read -p "Enter server hostname: " server
#server=$0
curl -s https://pulse.myorderbox.com/history_data | grep pulse.myorderbox.com | awk '{print $2}' | cut -d"'" -f2 > pulselist.txt
curl -s https://pulse.myorderbox.com/ | sed 's/href=/\n/g' | cut -d "'" -f 2 | grep "pulse.myorderbox.com" | grep -v "[=>]" >> pulselist.txt
for link in $( cat pulselist.txt )
do
#date1=$( curl -s $link | html2text | grep "Scheduled for" | tr "*" " " )
curl -s $link | grep $server > /dev/null
[[  $? -eq 0 ]] && { echo $link ; }
done

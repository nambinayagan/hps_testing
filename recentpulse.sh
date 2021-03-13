#!/bin/bash
read -p "Enter server hostname: " server
#server=$0
curl -s https://pulse.myorderbox.com/history_data | grep pulse.myorderbox.com | awk '{print $2}' | cut -d"'" -f2 > pulselist.txt
curl -s https://pulse.myorderbox.com/ | sed 's/href=/\n/g' | cut -d "'" -f 2 | grep "pulse.myorderbox.com" | grep -v "[=>]" >> pulselist.txt
for link in $( cat pulselist.txt )
do
#date1=$( curl -s $link | html2text | grep "Scheduled for" | tr "*" " " )
curl -s $link | grep $server > /dev/null
[[  $? -eq 0 ]] && { link2=$link ; newvar=$( curl -s $link | sed 's/<\/*[^>]*>//g' | grep -A1 "Scheduled start time" ); echo $newvar ; echo "Pulse link: $link" ; }
done
curl -s $link2 | grep "Removal of older PHP binaries" > /dev/null
[[  $? -eq 0 ]] && { echo "\n\n" ; echo "I see that the above given pulse link is for CPMH PHP Hard Upgrades. So you can refer to the template from below" ; echo "\n\n" ; sed -e "s|pulse_date|$datevar|g" -e "s|pulse_link|$link|g" template.txt ; }

#!/bin/bash/
domainpointing()
{
echo "Domain: $domain1"
domainIP1=$( dig $domain1 +short)
domainIP2=$( cat /var/cpanel/users/${username1##*( )} | grep "IP=" | cut -d'=' -f2 )
#echo -e "\n"
#[ $domainIP1 != $domainIP2 ] && { echo "$domain1 is pointing to $domainIP1 and not to hosting server IP address $domainIP2" ; exit ; } || { echo $domain1 is pointing to hosting server IP address: $domainIP2 ; }
[ $domainIP1 != $domainIP2 ] && { echo -e "\e[3;4;33mIs $domain1 pointing to assigned IP address\e[0m: ${red}No${reset}" ; exit ; } || { echo -e "\e[3;4;33mIs $domain1 pointing to assigned IP address\e[0m: ${green}Yes${reset}" ; }
}
sslchecker()
{
echo -e "\n"
curl --insecure -vvI https://$domain1 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' | grep "Let's Encrypt" > /dev/null
#[[  $? -eq 0 ]] && { printf "%${COLUMNS}s" " " | tr " " "=" ; printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title" ;  printf "%${COLUMNS}s" " " | tr " " "=" ; echo -e "\n" ; curl --insecure -vvI https://$domain1 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' ; printf "%${COLUMNS}s" " " | tr " " "=" ; } || { echo "SSL certificate is not installed for $domain1" ; printf "%${COLUMNS}s" " " | tr " " "*" ; exit 1; }
[[  $? -eq 0 ]] && { echo -e "\e[3;4;33mIs SSL certificate installed for $domain1\e[0m: ${green}Yes${reset}" ; curl --insecure -vvI https://$domain1 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' ; } || { echo -e "\e[3;4;33mIs SSL certificate installed for $domain1\e[0m: ${red}No${reset}" ; exit 1; }
}
checkredirection()
{
curl -iLs $domain1 | egrep 'HTTP|Location' | grep "https://" 2>&1 1>/dev/null
#[[  $? -eq 0 ]] && { echo "$domain1 is redirecting to a secure site" ; curl -iLs $domain1 | egrep 'HTTP|Location'; printf "%${COLUMNS}s" " " | tr " " "*" ; exit 1; }
[[  $? -eq 0 ]] && { echo -e "\e[3;4;33mIs $domain1 redirecting to a secure site $before\e[0m: ${green}Yes${reset}" ; curl -iLs $domain1 | egrep 'HTTP|Location'; echo "So exiting..." ; exit 1; } || { echo -e "\e[3;4;33mIs $domain1 redirecting to a secure site $before\e[0m: ${red}No${reset}" ; }
}
finddocroot()
{
        docroot1=$( /root/bin/ui $domain1 2> /dev/null | grep "Doc Root" | cut -d":" -f2 )

        [ -z "$docroot1" ] && exit;
}
echo -e "\n"
COLUMNS=$(tput cols)
red=`tput setaf 1`
green=`tput setaf 2`                                    #Adding colours
reset=$(tput sgr0)
#printf "%${COLUMNS}s" " " | tr " " "*"
read -p "Enter domain name: " domain1
username1=$( /root/bin/ui $domain1 2> /dev/null | grep "User:" | cut -d":" -f2 )
title="SSL Certificate Info"
#domainpointing
finddocroot
domainpointing
sslchecker
before="before adding of redirection code"
checkredirection
#echo " Document root is $docroot1 "
epooch=$( date +'%s' )
#echo Epoch time is $epooch
[ -f $docroot1/.htaccess ] &&  { cp $docroot1/.htaccess $docroot1/.htaccess_fssl_"$epooch" ; echo -e "\e[3;4;33mBackup of .htaccess file\e[0m: $docroot1/.htaccess_fssl_"$epooch"" ; }

echo -e "\n ##Start Redirection Code## \n\nHeader always set Content-Security-Policy" \""upgrade-insecure-requests;\"""\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n ##End Redirection Code##\n\n$( cat $docroot1/.htaccess 2> /dev/null )" > $docroot1/.htaccess
#ls -al $docroot1/.htaccess*
echo -e "${green}Redirection code added successfully${reset}"
echo -e "\e[3;4;33mNew .htaccess file with Force SSL code\e[0m: $docroot1/.htaccess"
before="after adding of redirection code"
checkredirection

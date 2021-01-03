#!/bin/bash/
domainpointing()
{
domainIP1=$( dig $domain1 +short)
domainIP2=$( cat /var/cpanel/users/${username1##*( )} | grep "IP=" | cut -d'=' -f2 )
echo -e "\n"
[ $domainIP1 != $domainIP2 ] && { echo "$domain1 is pointing to $domainIP1 and not to hosting server IP address $domainIP2" ; exit ; } || { echo $domain1 is pointing to hosting server IP address: $domainIP2 ; }
}
sslchecker()
{
echo -e "\n"
curl --insecure -vvI https://$domain1 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' | grep "Let's Encrypt" > /dev/null
[[  $? -eq 0 ]] && { printf "%${COLUMNS}s" " " | tr " " "=" ; printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title" ;  printf "%${COLUMNS}s" " " | tr " " "=" ; echo -e "\n" ; curl --insecure -vvI https://$domain1 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' ; printf "%${COLUMNS}s" " " | tr " " "=" ; } || { echo "SSL certificate is not installed for $domain1" ; printf "%${COLUMNS}s" " " | tr " " "*" ; exit 1; }

}
checkredirection()
{
curl -iLs $domain1 | egrep 'HTTP|Location' | grep "https://" 2>&1 1>/dev/null
[[  $? -eq 0 ]] && { echo "$domain1 is redirecting to a secure site" ; curl -iLs $domain1 | egrep 'HTTP|Location'; printf "%${COLUMNS}s" " " | tr " " "*" ; exit 1; }
}
finddocroot()
{
        docroot1=$( /root/bin/ui $domain1 2> /dev/null | grep "Doc Root" | cut -d":" -f2 )

        [ -z "$docroot1" ] && exit;
}
echo -e "\n"
COLUMNS=$(tput cols)
printf "%${COLUMNS}s" " " | tr " " "*"
read -p "Enter domain name: " domain1
username1=$( /root/bin/ui $domain1 2> /dev/null | grep "User:" | cut -d":" -f2 )
title="SSL Certificate Info"
domainpointing
finddocroot
sslchecker
checkredirection
#echo " Document root is $docroot1 "
epooch=$( date +'%s' )
#echo Epoch time is $epooch
[ -f $docroot1/.htaccess ] &&  { cp $docroot1/.htaccess $docroot1/.htaccess_fssl_"$epooch" ; echo "Existing .htaccess file is backed up in $docroot1/.htaccess_fssl_"$epooch"" ; }

echo -e "\n ##Start Redirection Code## \n\nHeader always set Content-Security-Policy" \""upgrade-insecure-requests;\"""\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n ##End Redirection Code##\n\n$( cat $docroot1/.htaccess 2> /dev/null )" > $docroot1/.htaccess
#ls -al $docroot1/.htaccess*

echo "New .htaccess file with Force SSL code has been added in $docroot1/.htaccess"
#cat $docroot1/.htaccess
echo -e "\n"
title2="***Checking redirection for $domain1***"
printf "%${COLUMNS}s" " " | tr " " "=" ; printf "%*s\n" $(((${#title2}+$COLUMNS)/2)) "$title2" ;  printf "%${COLUMNS}s" " " | tr " " "=" ;
#printf "%*s\n" $(((${#title2}+$COLUMNS)/2)) "$title2"
#echo "Checking redirection for $domain1"
curl -iLs $domain1 | egrep 'HTTP|Location'
#echo -e "\n"
printf "%${COLUMNS}s" " " | tr " " "*"

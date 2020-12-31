#!/bin/bash/
domainpointing()
{
domainIP1=$( dig $domain1 +short)
domainIP2=$( cat /var/cpanel/users/${username1##*( )} | grep "IP=" | cut -d'=' -f2 )
[ $domainIP1 != $domainIP2 ] && { echo "$domain1 is pointing to $domainIP1 and not to hosting server IP address $domainIP2" ; exit ; } || { echo $domain1 is pointing to $domainIP2 ; }
}
checkredirection()
{
curl -iLs $domain1 | egrep 'HTTP|Location' | grep "https://" 2>&1 1>/dev/null
[[  $? -eq 0 ]] && { echo "$domain1 is redirecting to a secure site" ; curl -iLs $domain1 | egrep 'HTTP|Location'; exit 1; }
}
finddocroot()
{
        docroot1=$( /root/bin/ui $domain1 | grep "Doc Root" | cut -d":" -f2 2> /dev/null )

        [ -z "$docroot1" ] && exit;
}

read -p "Enter username: " domain1
username1=$( /root/bin/ui $domain1 | grep "User:" | cut -d":" -f2 2> /dev/null )
#domainpointing
finddocroot
checkredirection
#docroot1="/home/nambinayagan.y/hom/atestuser/public_html"
#[ -z "$docroot1" ] && return;
echo " Document root is $docroot1 "
epooch=$( date +'%s' )
echo Epoch time is $epooch
#touch $docroot1/.htaccess
#echo adding >> $docroot1/.htaccess
#echo Before
#cat $docroot1/.htaccess
#docroot2=$( $docroot1/.htaccess$epooch )
#[ -f "$docroot1/.htaccess" ] && { mv $docroot1/.htaccess $docroot1/.htaccess"$epooch" ; move=1 ; }
[ -f $docroot1/.htaccess ] &&  cp $docroot1/.htaccess $docroot1/.htaccess_fssl_"$epooch"

echo -e "\n ##Start Redirection Code## \n\nHeader always set Content-Security-Policy" \""upgrade-insecure-requests;\"""\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n ##End Redirection Code##\n$( cat $docroot1/.htaccess )" > $docroot1/.htaccess
#echo -e \n  >> $docroot1/.htaccess
#echo After
ls -al $docroot1/.htaccess*

cat $docroot1/.htaccess
curl -iLs $domain1
#ls -al $docroot1 | grep htaccess

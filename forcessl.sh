#!/bin/bash/
finddocroot()
{
        docroot1=$( /root/bin/ui $user1 | grep "Doc Root" | cut -d":" -f2 )

        [ -z "$docroot1" ] && exit;
}

read -p "Enter username: " user1
finddocroot
#docroot1="/home/nambinayagan.y/hom/atestuser/public_html"
#[ -z "$docroot1" ] && return;
echo " Document root is $docroot1 "
epooch=$( date +'%s' )
echo $epooch
#touch $docroot1/.htaccess
#echo adding >> $docroot1/.htaccess
#echo Before
cat $docroot1/.htaccess

[ -f "$docroot1/.htaccess" ] && { mv $docroot1/.htaccess $docroot1/.htaccess_$epooch ; move=1 ; }
echo -e "## Start Redirection code ##" >> $docroot1/.htaccess
echo -e \n >> $docroot1/.htaccess
echo -e "\nHeader always set Content-Security-Policy" \""upgrade-insecure-requests;\"""\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n" >> $docroot1/.htaccess
[[  $move -eq 1 ]]  && cat $docroot1/.htaccess_$epooch >> $docroot1/.htaccess ;
#echo -e \n  >> $docroot1/.htaccess
#echo After
ls -al $docroot1/.htaccess_$epooch
cat $docroot1/.htaccess
#ls -al $docroot1 | grep htaccess

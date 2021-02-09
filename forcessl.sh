#!/bin/bash/
finddocroot()
{
        docroot1=$( /root/bin/ui $user1 | grep "Doc Root" | cut -d":" -f2 )

        [ -z "$docroot1" ] && exit;
}

read -p "Enter username: " user1
finddocroot
echo " Document root is $docroot1 "
epooch=$( date +'%s' )
echo $epooch

[ -f $docroot1/.htaccess ] &&  cp $docroot1/.htaccess $docroot1/.htaccess_fssl_"$epooch"

echo -e "\n ##Start Redirection Code## \n\nHeader always set Content-Security-Policy" \""upgrade-insecure-requests;\"""\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n ##End Redirection Code##\n$( cat $docroot1/.htaccess )" > $docroot1/.htaccess

ls -al $docroot1/.htaccess*

cat $docroot1/.htaccess


#!/bin/bash/

docroot1="/home/nambinayagan.y/hom/atestuser/public_html"
[ -z "$docroot1" ] && return;
echo $docroot1
epooch=$( date +'%s' )
echo $epooch
#touch $docroot1/.htaccess
echo adding >> $docroot1/.htaccess
echo Before
cat $docroot1/.htaccess

[ -z "$docroot1/.htaccess" ] &&  echo "htaccess absent"  ||  mv $docroot1/.htaccess $docroot1/.htaccess_$epooch;
echo -e "\nHeader always set Content-Security-Policy" \""upgrade-insecure-requests;\"""\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n" >> $docroot1/.htaccess
cat $docroot1/.htaccess_$epooch >> $docroot1/.htaccess
echo -e \n
echo After
cat $docroot1/.htaccess
#ls -al $docroot1 | grep htaccess

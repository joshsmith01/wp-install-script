#!/bin/bash -e

#Output commands to get site details
read -p "New local site name: " SITE

#change path to SITEPATH =" your path/${SITE}"
SITEPATH="/Users/joshsmith01/sites/${SITE}"

# private/etc/hosts
# Change extension (l.localhost.com) to match your normal url pattern
echo "127.0.0.1\t${SITE}.localhost.com" >> /private/etc/hosts

#http-vhosts.conf
#Change extension (l.localhost.com) to match your normal url pattern
VHOSTSFILE="/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf"


echo "<VirtualHost *:80>" >> $VHOSTSFILE
echo "\tServerName ${SITE}.localhost.com" >>$VHOSTSFILE
echo "\tDocumentRoot \"${SITEPATH}\"" >> $VHOSTSFILE
echo "\t<Directory ${SITEPATH}>" >> $VHOSTSFILE
echo "Options Indexes FollowSymLinks MultiViews" >> $VHOSTSFILE
echo "AllowOverride All" >> $VHOSTSFILE
echo "Order allow,deny" >> $VHOSTSFILE
echo "allow from all" >> $VHOSTSFILE
echo "</Directory>" >> $VHOSTSFILE
echo "</VirtualHost>" >> $VHOSTSFILE


#Restarts MAMP (changed to your url if apachectl.sh is in a differnet location on your  MAMP install)
/Applications/MAMP/bin/apache2/bin/apachectl restart;

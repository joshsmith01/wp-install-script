#!/bin/bash -e
# Possible Trouble Shooting Tip
# *Ensure the PHP that MAMP is using is the same as the the PHP wp-cli is using
# 

clear
echo "================================================================="
echo "Awesome WordPress and FoundationPress Theme Installer!!"
echo "================================================================="


# accept the name of our website
echo "$(tput setaf 4)$(tput setab 7)Site Name: $(tput sgr 0)"
read -e sitename

# accept a comma separated list of pages
echo "$(tput setaf 4)$(tput setab 7)Add a comma separated list of pages: $(tput sgr 0)"
read -e allpages

# add a simple yes/no confirmation before we proceed
echo "$(tput setaf 4)$(tput setab 7)Run Install? (y/n) $(tput sgr 0)"
read -e run


## variables ##
# clean up site names and directory names
dbname="$(echo -e "${sitename}" | tr -d '[[:space:]]' | tr '[:upper:]' '[:lower:]' | head -c 10)"
sitedirectory="$(echo -e "${sitename}" | tr -s ' ' '-' | tr '[:upper:]' '[:lower:]')"

# My path to my server host directory
# Those who clone this will likely need to change this path to their own hosting directory. 
dirpath=$HOME/sites/
# assign user naming conventions
wpuser='dev_'${sitedirectory}
fpthemename=${sitename}'_theme'
adminemail='joshsmith01@me.com'
siteurl='http://'${sitedirectory}


# # test to see if the directory can be made
# mkdir -p /Applications/MAMP/Library/vhosts;
# mkdir -p /Applications/MAMP/Library/vhosts/domains;
# 
# 
# # Add vhost
# touch /Applications/MAMP/Library/vhosts/domains/${sitedirectory};
#  
#   echo "<VirtualHost *:80>
#     DocumentRoot "~/sites/${sitedirectory}"
#     ServerName ${sitedirectory}
#     <Directory "~/sites/${sitedirectory}">
#         Options All
#         AllowOverride All
#         Order allow,deny
#         Allow from all
#     </Directory>
# </VirtualHost>" >> /Applications/MAMP/Library/vhosts/domains/${sitedirectory};
#  
#   echo "127.0.0.1 ${sitedirectory}" >> changehosts;
#   echo "past the etc"
#   # Restart MAMP
#   sudo /Applications/MAMP/Library/bin/httpd -f "/Library/Application Support/appsolute/MAMP PRO/conf/httpd.conf" -k restart
#   echo "mamp restart"
#   exit


# if the user didn't say no, then go ahead and install
if [ "$run" == n ] ; then
exit
else

# check to see if the desired directory exists and create it if it doesn't
if [ ! -d ${dirpath}$sitedirectory ] ; then
  mkdir ${dirpath}$sitedirectory
fi

# move controller into that newly created directory
cd ${dirpath}$sitedirectory

wp core download
# delete all themes and then reinstall twentyfifteen

wp core config --dbname=$dbname --dbuser=root --dbpass=root --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# create the wp-config file with our standard setup
# parse the current directory name
sitedirectory=${PWD##*/}

# generate random 12 character password
password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)


# copy password to clipboard
echo $password | pbcopy

# create database, and install WordPress
wp db create
wp core install --url="$siteurl" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="$adminemail"

# discourage search engines
wp option update blog_public 0

# posts per page
wp option update posts_per_page 6

# delete stock post 
wp post delete 1 --force

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)
wp post create --post_type=page --post_title=About --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)
wp post create --post_type=page --post_title=Contact --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)
wp post create --post_type=page --post_title=Store --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)


# set homepage as front page
wp option update show_on_front 'page'

# set homepage to be the new page
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids)

# create all of the pages
export IFS=","
for page in $allpages; do
	wp post create --post_type=page --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids) --post_title="$(echo $page | sed -e 's/^ *//' -e 's/ *$//')"
done

# set pretty urls
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

## plugins
# delete some and...
wp plugin delete hello
# install install others
wp plugin install wordpress-seo
if [ -c ~/Google Drive/Tribusmedia/Development/Downloads/WP Migrate DB Pro.zip ]
then
  wp plugin install ~/Google Drive/Tribusmedia/Development/Downloads/WP Migrate DB Pro.zip
  else wp plugin install wp-migrate-db --activate
fi
wp plugin install WPide --activate
wp plugin install woocommerce --activate
wp plugin install contact-form-7 --activate
wp plugin install advanced-custom-fields --activate

## themes
# removes the inactive themes that automatically come wth an fresh installation of WP. Since WP needs one
# active theme, this command only removes the inactive ones. -JMS
wp theme list --status=inactive --field=name | while read THEME; do wp theme delete $THEME; done;

# install the tm-starter-01 theme
cd $dirpath$sitedirectory/wp-content/themes/
# If you get errors, use https to clone
# git clone https://joshsmith_tribus@bitbucket.org/tribusmedia/tm-starter-01.git
git clone git@bitbucket.org:tribusmedia/tm-starter-01.git
mv tm-starter-01 $fpthemename
cd $fpthemename
sudo npm install

clear
# Change the newly cloned theme style.css to the site's name so it displays 
# correctly in the Dashboard. -JMS
themename_old='Theme Name:         tm-starter-01'
themename_new='Theme Name:         '$fpthemename
pwd
sed -i '' "s%$themename_old%$themename_new%g" $dirpath$sitedirectory/wp-content/themes/$fpthemename/style.css

wp theme activate $fpthemename
# create a navigation bar
wp menu create "Main Navigation"

# add pages to navigation
export IFS=" "
for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids); do
	wp menu item add-post main-navigation $pageid
done

# assign navigaiton to primary location
wp menu location assign main-navigation top-bar-r

clear

# Open the new website with Google Chrome
/usr/bin/open -a "/Applications/Google Chrome.app" "http://$sitedirectory/wp-login.php"
cd ${dirpath}${sitedirectory}/wp-content/themes/$fpthemename
# startbitbucket - creates remote bitbucket repo and adds it as git remote to cwd
# Users should use ssh if you can. It'll save you time from adding usernames and passwords.


#     echo 'Enter Your Bitbucket Credentials'
#     echo 'Username?'
#     read username
#     echo 'Password?'
#     read password

#     git remote set-url origin https://$username@bitbucket.org/$username/$fpthemename.git
#     curl --user $username:$password https://api.bitbucket.org/1.0/repositories/ --data name=$fpthemename --data is_private='true'

    git remote set-url origin https://git@bitbucket.org:tribusmedia/$fpthemename.git

    git push -u origin --all
    git push -u origin --tags
# END check if core is downloaded and download it
# fi


echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "================================================================="

fi
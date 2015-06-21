#!/bin/bash -e

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

# 
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
#   /Applications/MAMP/bin/apache2/bin/apachectl restart;




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

# discourage search engines
wp option update posts_per_page 6

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)

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
# delete hello dolly
wp plugin delete hello
# install seo yoast plugin
wp plugin install wordpress-seo

## themes
# removes the inactive themes that automattically come wth an fresh installation of WP. Since WP needs one
# active theme, this command only removes the inactive one. -JMS
wp theme list --status=inactive --field=name | while read THEME; do wp theme delete $THEME; done;

# install the FoundationPress theme
cd $dirpath$sitedirectory/wp-content/themes/
git clone https://github.com/joshsmith01/FoundationPress.git
mv FoundationPress $fpthemename
cd $fpthemename
sudo npm install && bower install && grunt build

clear
# Change the newly cloned theme style.css to the site's name so it displays 
# correctly in the Dashboard. -JMS
themename_old='Theme Name:         FoundationPress'
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

echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "================================================================="

# Open the new website with Google Chrome
/usr/bin/open -a "/Applications/Google Chrome.app" "http://$sitedirectory/wp-login.php"
cd ${dirpath}${sitedirectory}/wp-content/themes/$fpthemename
# startbitbucket - creates remote bitbucket repo and adds it as git remote to cwd
    echo 'Username?'
    read username
    echo 'Password?'
    read password

    git remote set-url origin https://$username@bitbucket.org/$username/$fpthemename.git
    
    curl --user $username:$password https://api.bitbucket.org/1.0/repositories/ --data name=$fpthemename --data is_private='true'

    git push -u origin --all
    git push -u origin --tags
# END check if core is downloaded and download it
# fi
fi
# wp-install-script
Install WordPress and a customized version of FoundationPress

## Script Location
Save this `.sh` file to your scripts directory. If you don't have a scripts directory make one. I had to make one and I called it `Scripts` I placed it in my home folder, `joshsmith01/Scripts/`. Easy!

## Edit Hidden Files
Next, you'll probably want to invoke this script with a simple one-line command in your Terminal so you'll have to make some more changes. You have a hidden file called `~/.bash_profile`, go to that. You might need to view hidden files. You'll have to add an alias like so: `alias wpinstall="~/Scripts/wpinstall/wpinstall.sh"`. Now you just type that alias in Terminal and you'll be set.

While you're in `.bash-profile` you'll most likely need to make some other changes. You'll have to adjust where this script and the WP-CLI reads your PHP and the "`PATH`" from on your machine. Here are the three lines from my `.bash-profile` file: 

`export MAMP_PHP=/Applications/MAMP/bin/php/php5.6.6/bin
export PATH="$MAMP_PHP:$PATH:/Applications/MAMP/Library/bin/"
alias wpinstall="~/Scripts/wpinstall/wpinstall.sh"`

By the way, this is all that is in this file. 

You have a PATH that your machine uses as a starting point for a lot of things. One of those things is the location of the PHP version you're going to use. I have MAMP installed and use that as my server. I have also created a custom location for my server directory instead of the `/htdocs/` that MAMP has as a default. The PATH can be referenced as $PATH. Replace my path to my PHP with your path to yours.

## Install WP-CLI
You'll also need to install WP-CLI. You can do that from [here](http://wp-cli.org/).
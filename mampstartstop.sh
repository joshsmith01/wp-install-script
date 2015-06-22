#!/bin/bash

##
# Apache HTTP Server
##

. /etc/rc.common
MAMP_mysql_error_log_MAMP="/Applications/MAMP/logs/mysql_error_log.err"
MAMP_php_error_log_MAMP="/Applications/MAMP/logs/php_error.log"

mysqlPath="/Library/Application Support/appsolute/MAMP PRO/db/mysql"
mysqlTmpPath=/Applications/MAMP/tmp/mysql
mysqlTmpdirPath=/Applications/MAMP/tmp/mysql/tmpdir
phpTmpPath=/Applications/MAMP/tmp/php
eacceleratorTmpPath=/Applications/MAMP/tmp/eaccelerator
xCacheMmapPath=/Applications/MAMP/tmp/xcache
xCacheCoredumpDirectory=/Applications/MAMP/tmp/phpcore
fcgiTmpPath=/Applications/MAMP/tmp/fcgi_ipc
mysqlLogPath="/Applications/MAMP/logs/mysql_error_log.err"
phpLogPath="/Applications/MAMP/logs/php_error.log"
mysqlConfPath=/Applications/MAMP/tmp/mysql/my.cnf
apacheUser="www"
mysqlUser="mysql"

Log()
{
    logger -t "MAMP" $1
}


Stop ()
{
    if test -f /Applications/MAMP/Library/logs/httpd.pid; then
		Log "Stopping MAMP Apache server"
		/Applications/MAMP/Library/bin/apachectl -f"/Library/Application Support/appsolute/MAMP PRO/conf/httpd.conf" -k stop
	fi
	
    if test -f /Applications/MAMP/tmp/mysql/mysql.pid; then
		Log "Stopping MAMP MySQL server"
		/bin/kill `cat /Applications/MAMP/tmp/mysql/mysql.pid`
	fi
    
}

Start ()
{
	Log "Starting MAMP Apache web server"
    Stop
    
	chmod -R a+w /Applications/MAMP/db/sqlite
	if test -d ${phpTmpPath}; then chown -R ${apacheUser} ${phpTmpPath}; fi
	if test -d ${eacceleratorTmpPath}; then chown -R ${apacheUser} ${eacceleratorTmpPath}; fi
	if test -d ${fcgiTmpPath}; then chown -R ${apacheUser} ${fcgiTmpPath}; fi
	if test -f ${xCacheMmapPath}; then chown ${apacheUser} ${xCacheMmapPath}; fi
	if test -d ${xCacheCoredumpDirectory}; then chown -R ${apacheUser} ${xCacheCoredumpDirectory}; fi
	touch "${phpLogPath}"
	chown ${apacheUser} "${phpLogPath}"
	/Applications/MAMP/Library/bin/apachectl -f"/Library/Application Support/appsolute/MAMP PRO/conf/httpd.conf" -k start
	
	Log "Starting MAMP MySQL server"
	chown ${mysqlUser} "${mysqlLogPath}"
	chmod 0640 "${mysqlLogPath}"
	
	chown -R ${mysqlUser} "${mysqlPath}"
	if [ ! -d ${mysqlTmpdirPath} ]; then mkdir ${mysqlTmpdirPath}; fi
	chown -R ${mysqlUser} ${mysqlTmpPath}

	for i in "${mysqlPath}"/*; do
		if [ -f "$i" ]; then
			chmod 0660 "$i"
		else
			if [ -d "$i" ]; then
				chmod -R 0600 "$i"
				chmod 0775 "$i"
			fi
 		fi
	done
	
	if [ -f ${mysqlConfPath} ]; then
		chown ${mysqlUser} ${mysqlConfPath}
		chmod 0660 ${mysqlConfPath}
	fi
	
	/Applications/MAMP/Library/bin/mysqld_safe --defaults-file=${mysqlConfPath} --user=${mysqlUser} --port=MAMP_MysqlPort_MAMP --socket=/Applications/MAMP/tmp/mysql/mysql.sock --pid-file=/Applications/MAMP/tmp/mysql/mysql.pid --log-error="$mysqlLogPath" --tmpdir=${mysqlTmpdirPath} --datadir=/Library/Application\ Support/appsolute/MAMP\ PRO/db/mysql
}


Restart ()
{
	Stop
	Start
}

"$1" &
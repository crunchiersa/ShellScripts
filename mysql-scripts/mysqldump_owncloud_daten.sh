#!/bin/bash
# Author: crunchie 10.06.2018
# Script to execute mysqldump and backup database to /private-backup/owncloud_rsnapshot/
# Define User and password
sqluser="dumpuser"
sqlpw="Password"

# define variables for current different date formats
cdate=$(date +%Y-%m-%d_%H-%M)
currentday=$(date +%Y-%m-%d)
day=$(date +%d)
lastmonth=$(date +%m -d 'last month')
currentyear=$(date +%Y)
lastyear=$(date +%Y -d 'last year')

# Execute the mysqldump and change owner of file to root. Current date at beginning of dump.
mysqldump -u "$sqluser" -p$sqlpw "ownclouddb" > /private-backup/owncloud_rsnapshot/"$currentday"_ownclouddb.sql
chown root:root /private-backup/owncloud_rsnapshot/"$currentday"_ownclouddb.sql

# Run only on first day of every month --> archive old sql-dumps and delete the dumps.
if [ "$day" == "1" ]; then
        if [ "$lastmonth" == "12" ]; then
        # If current month is January --> Archive for old sql-dumps needs current year adjusted as last year.
        tar -czf "$lastyear"-"$lastmonth"_sql.tar.gz -C /private-backup/owncloud_rsnapshot/ "$lastyear"-"$lastmonth"-*_ownclouddb.sql
        rm /private-backup/owncloud_rsnapshot/"$lastyear"-"$lastmonth"-*_ownclouddb.sql
        elif [ ! "$lastmonth" == "12" ]; then
        # Archive sql-dumps from last month and delete original dumps afterwards.
        tar -czf "$currentyear"-"$lastmonth"_sql.tar.gz -C /private-backup/owncloud_rsnapshot/ "$currentyear"-"$lastmonth"-*_ownclouddb.sql
        rm /private-backup/owncloud_rsnapshot/"$currentyear"-"$lastmonth"-*_ownclouddb.sql
        fi
fi

exit 0

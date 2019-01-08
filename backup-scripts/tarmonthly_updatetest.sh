#!/bin/bash
#Set Variable month as two digit month of date
month=$(date +%Y-%m)
last_month=`date --date "last month" +%Y-%m`
#echo $last_month
#Search for files with current month
cd /home/crunchie/Desktop/WichtigeDaten/Test
tar -czf "$last_month"_Updatelog.tar.gz "$last_month"-*.tar
rm -f "$last_month"-*.tar
exit 0

#!/bin/bash

# check if executing user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# define two variables for current day and date including hour and minute
cdate=$(date +%Y-%m-%d_%H-%M)
day=$(date +%Y-%m-%d)
user=crunchie ## ADD USERNAME HERE

# Check if directory fo current day already exists, if not create such directory
if [ ! -d /root/UpdateLog/"$day"_Logs/ ]; then
        mkdir -p /root/UpdateLog/"$day"_Logs
fi

# Update Sources from  /etc/apt/source.list
apt-get update > /root/UpdateLog/"$day"_Logs/output_update

# Check if upgrades are available and install available upgrades
apt-get dist-upgrade -y >> /root/UpdateLog/"$day"_Logs/output_update

# move files with output from above commands to daily folder 
cd /root/UpdateLog/"$day"_Logs
for file in output_update; do
mv  "$file" "$cdate""$file"
done

# Create Folder in home of user specified in user-variable.

if [ ! -d /home/"$user"/UpdateLog/"$day"_Logs/ ]; then
        mkdir -p /home/"$user"/UpdateLog/"$day"_Logs
fi


# Sync folders and change owner of folder in /home/pi
rsync -r /root/UpdateLog/"$day"_Logs/ /home/"$user"/UpdateLog/"$day"_Logs/
chown -R "$user":"$user" /home/"$user"/UpdateLog/

exit 0

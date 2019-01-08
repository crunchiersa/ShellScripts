
#!/bin/bash
##AUTHOR: crunchie
##DATE: 31.12.2018
##update_and_move.sh - Check for updates and automatically install any available updates. 
##Version: 2.0 
#NEW: Check fo availability of apt-get and yum (depending on which update-client is used) use the available client accordingly.
#	Customizable which user to copy the logs to.


# check if executing user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# define two variables for current day and date including hour and minute
cdate=$(date +%Y-%m-%d_%H-%M)
day=$(date +%Y-%m-%d)
user=username ## ADD USERNAME HERE


# Check if directory fo current day already exists, if not create such directory
if [ ! -d /root/UpdateLog/"$day"_Logs/ ]; then
        mkdir -p /root/UpdateLog/"$day"_Logs
fi

# Check whether yum or apt-get are available --> use one accordingly
which apt-get
apt=$?
which yum
yum=$?

if [ $apt == 0 -a $yum == 1 ]; then
apt-get update > /root/UpdateLog/"$day"_Logs/output_update
elif [ $apt == 1 -a $yum == 0 ]; then
yum check-update > /root/UpdateLog/"$day"_Logs/output_update
fi

# Check if upgrades are available and install available upgrades
if [ $apt == 0 -a $yum == 1 ]; then
apt-get dist-upgrade -y >> /root/UpdateLog/"$day"_Logs/output_update
elif [ $apt == 1 -a $yum == 0 ]; then
yum update -y >> /root/UpdateLog/"$day"_Logs/output_update
fi

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

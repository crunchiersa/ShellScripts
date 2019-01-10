#!/bin/bash
##AUTHOR: crunchie
##DATE: 20.06.2018
##set_apt-sources.sh - Change content of /etc/apt/sources.list depending on whether local aptcache-server ist available
##Version: 2.0
##Changes: variables os and version are now automatically determined. Added comments to sources.list for seperate repositories. Added customization for raspbian and debian for stretch and jessie.
##Added check for whether executing user is root. Minor optimizations.

# Check if executing User is root, if not --> exit with error!
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Set variables; server=IP of apt-cache-server; os= debian or raspbian, automatically detected --> source-entries must be different!
server=IP/FQDN # Should be IP or FQDN for wanted apt-cache/apt-mirror.
port=3142 # Should be port set in config of apt-cache/apt-mirror.
system=$(cat /etc/os-release | grep _NAME= | sed -r 's/.{13}//' | sed -r 's/.{23}$//' | tr '[:upper:]' '[:lower:]')"-"$(cat /etc/*-release | grep VERSION= | sed -r 's/.{12}//' | sed -r 's/.{2}$//')

# Check whether the defined server is available - source for ping-command: https://stackoverflow.com/questions/8937663/shell-script-to-check-wether-a-server-is-reachable
case $system in
	raspbian-stretch)
		# Remove /etc/apt/sources.list and recreate an empty file to be filled according to whether the local server is reachable.
                rm /etc/apt/sources.list
                touch /etc/apt/sources.list
		echo "## This file was created via script! Please do not edit file by hand! ##" >> /etc/apt/sources.list
		ping -c1 -W1 -q $server &>/dev/null
		status=$( echo $? )
		if [[ $status == 0 ]] ; then
			echo "deb http://$server:$port/mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi" >> /etc/apt/sources.list
			echo "deb http://$server:$port/download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
		else
			echo "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi" >> /etc/apt/sources.list
                        echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
		fi
		;;
	debian-stretch)
		# Remove /etc/apt/sources.list and recreate an empty file to be filled according to whether the local server is reachable.
                rm /etc/apt/sources.list
                touch /etc/apt/sources.list
		echo "## This file was created via script! Please do not edit file by hand! ##" >> /etc/apt/sources.list
		ping -c1 -W1 -q $server &>/dev/null
                status=$( echo $? )
		if [[ $status == 0 ]] ; then
			echo "# Stretch non-free" >> /etc/apt/sources.list
			echo "deb http://$server:$port/ftp.uni-mainz.de/debian/ stretch main non-free" >> /etc/apt/sources.list
			echo "deb-src http://$server:$port/ftp.uni-mainz.de/debian/ stretch main non-free" >> /etc/apt/sources.list
			echo "# stretch security" >> /etc/apt/sources.list
			echo "deb http://$server:$port/security.debian.org/debian-security stretch/updates main contrib" >> /etc/apt/sources.list
			echo "deb-src http://$server:$port/security.debian.org/debian-security stretch/updates main contrib" >> /etc/apt/sources.list
			echo "# stretch-updates, previously know as 'volatile'" >> /etc/apt/sources.list
			echo "deb http://$server:$port/ftp.uni-mainz.de/debian/ stretch-updates main contrib" >> /etc/apt/sources.list
			echo "deb-src http://$server:$port/ftp.uni-mainz.de/debian/ stretch-updates main contrib" >> /etc/apt/sources.list
                else
			echo "# stretch non-free" >> /etc/apt/sources.list
                        echo "deb http://ftp.uni-mainz.de/debian/ stretch main non-free" >> /etc/apt/sources.list
                        echo "deb-src http://ftp.uni-mainz.de/debian/ stretch main non-free" >> /etc/apt/sources.list
			echo "# stretch-security" >> /etc/apt/sources.list
                        echo "deb http://security.debian.org/debian-security stretch/updates main contrib" >> /etc/apt/sources.list
                        echo "deb-src http://security.debian.org/debian-security stretch/updates main contrib" >> /etc/apt/sources.list
			echo "# stretch-updates, previously known as 'volatile'" >> /etc/apt/sources.list
                        echo "deb http://ftp.uni-mainz.de/debian/ stretch-updates main contrib" >> /etc/apt/sources.list
                        echo "deb-src http://ftp.uni-mainz.de/debian/ stretch-updates main contrib" >> /etc/apt/sources.list
                fi
		;;
	raspbian-jessie)
		# Remove /etc/apt/sources.list and recreate an empty file to be filled according to whether the local server is reachable.
                rm /etc/apt/sources.list
                touch /etc/apt/sources.list
		echo "## This file was created via script! Please do not edit file by hand!##" >> /etc/apt/sources.list
		ping -c1 -W1 -q $server &>/dev/null
		status=$( echo $? )
		if [[ $status == 0 ]] ; then
			echo "deb http://$server:$port/mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi" >> /etc/apt/sources.list
			echo "deb http://$server:$port/download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
		else
			echo "deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi" >> /etc/apt/sources.list
                        echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
		fi
		;;
	debian-jessie)
		# Remove /etc/apt/sources.list and recreate an empty file to be filled according to whether the local server is reachable.
                rm /etc/apt/sources.list
                touch /etc/apt/sources.list
		echo "## This file was created via script! Please do not edit file by hand! ##" >> /etc/apt/sources.list
		ping -c1 -W1 -q $server &>/dev/null
                status=$( echo $? )
		if [[ $status == 0 ]] ; then
			echo "deb http://$server:$port/ftp.uni-mainz.de/debian/ jessie main" >> /etc/apt/sources.list
			echo "deb-src http://$server:$port/ftp.uni-mainz.de/debian/ jessie main" >> /etc/apt/sources.list
			echo "deb http://$server:$port/security.debian.org/debian-security jessie/updates main contrib" >> /etc/apt/sources.list
			echo "deb-src http://$server:$port/security.debian.org/debian-security jessie/updates main contrib" >> /etc/apt/sources.list
			echo "deb http://$server:$port/ftp.uni-mainz.de/debian/ jessie-updates main contrib" >> /etc/apt/sources.list
			echo "deb-src http://$server:$port/ftp.uni-mainz.de/debian/ jessie-updates main contrib" >> /etc/apt/sources.list
                else
                        echo "deb http://ftp.uni-mainz.de/debian/ jessie main" >> /etc/apt/sources.list
                        echo "deb-src http://ftp.uni-mainz.de/debian/ jessie main" >> /etc/apt/sources.list
                        echo "deb http://security.debian.org/debian-security jessie/updates main contrib" >> /etc/apt/sources.list
                        echo "deb-src http://security.debian.org/debian-security jessie/updates main contrib" >> /etc/apt/sources.list
                        echo "deb http://ftp.uni-mainz.de/debian/ jessie-updates main contrib" >> /etc/apt/sources.list
                        echo "deb-src http://ftp.uni-mainz.de/debian/ jessie-updates main contrib" >> /etc/apt/sources.list
                fi
		;;
	*)
		# Do nothing, as no sources are defined.
		echo "Your System could not be determined, nothing will be changed!"
		;;
esac
exit 0

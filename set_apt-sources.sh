#!/bin/bash
##AUTHOR: crunchie
##DATE: 13.01.2019
##set_apt-sources.sh - Change content of /etc/apt/sources.list depending on whether local aptcache-server is available
##Version: 2.1
## CHANGES V2.0: variables os and version are now automatically determined. Added comments to sources.list for seperate repositories. Added customization for raspbian and debian for stretch and jessie.
## Added check for whether executing user is root. Minor optimizations.
## CHANGES V2.1: Defined function for creating different apt-sources-files. Using variables for defining sources instead of release-version-specific strings.

######################
## RASPBIAN SOURCES ##
######################

set_rasbian_source () {

if [ "$1" == "local" ]; then
    echo "deb http://$server:$port/$rasp_url/$distri/ $release main contrib non-free rpi" >> /etc/apt/sources.list
elif [ "$1" == "remote" ]; then
    echo "deb http://$rasp_url/$distri/ $release main contrib non-free rpi" >> /etc/apt/sources.list
fi
}

####################
## DEBIAN SOURCES ##
####################

set_debian_source () {

if [ "$1" == "lokal" ]; then
    echo "# $release non-free" >> /etc/apt/sources.list
    echo "deb http://$server:$port/$deb_url/$distri/ $release main non-free" >> /etc/apt/sources.list
    echo "deb-src http://$server:$port/$deb_url/$distri/ $release main non-free" >> /etc/apt/sources.list

    echo "# $release security" >> /etc/apt/sources.list
    echo "deb http://$server:$port/security.debian.org/debian-security $release/updates main contrib" >> /etc/apt/sources.list
    echo "deb-src http://$server:$port/security.debian.org/debian-security $release/updates main contrib" >> /etc/apt/sources.list

    echo "# $release-updates, previously know as 'volatile'" >> /etc/apt/sources.list
    echo "deb http://$server:$port/$deb_url/$distri/ $release-updates main contrib" >> /etc/apt/sources.list
    echo "deb-src http://$server:$port/$deb_url/$distri/ $release-updates main contrib" >> /etc/apt/sources.list
elif [ "$1" == "remote" ]; then
    echo "# $release non-free" >> /etc/apt/sources.list
    echo "deb http://$deb_url/$distri/ $release main non-free" >> /etc/apt/sources.list
    echo "deb-src http://$deb_url/$distri/ $release main non-free" >> /etc/apt/sources.list
    
    echo "# $release security" >> /etc/apt/sources.list
    echo "deb http://security.debian.org/debian-security $release/updates main contrib" >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security $release/updates main contrib" >> /etc/apt/sources.list
    
    echo "# $release-updates, previously know as 'volatile'" >> /etc/apt/sources.list
    echo "deb http://$deb_url/$distri/ $release-updates main contrib" >> /etc/apt/sources.list
    echo "deb-src http://$deb_url/$distri/ $release-updates main contrib" >> /etc/apt/sources.list
fi
}

#######################
## GENERAL FUNCTIONS ##
#######################

rm_original_source () {

if [ -d /etc/orig ]; then
    mv /etc/apt/sources.list /etc/orig
    touch /etc/apt/sources.list
    echo "## This file was created via script! Please do not edit file by hand! ##" >> /etc/apt/sources.list
elif [ ! -d /etc/orig ]; then
    mkdir -p /etc/orig
    mv /etc/apt/sources.list /etc/orig
    touch /etc/apt/sources.list
    echo "## This file was created via script! Please do not edit file by hand! ##" >> /etc/apt/sources.list
fi
}

set_new_file () {

ping -c1 -W1 -q $server &>/dev/null
status=$( echo $? )
if [[ $status == 0 ]] ; then
    set_$1_source lokal       
else
    set_$1_source remote
fi
}

###################
## EXECUTE BLOCK ##
###################

# Check if executing User is root, if not --> exit with error!
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Set variables; server=IP of apt-cache-server; os= debian or raspbian, automatically detected --> source-entries must be different!
deb_url="DEBIAN MIRROR URL"             # BASE-URL of closest debian-mirror use netselect-apt or https://www.debian.org/mirror/list to find closes/best server.
rasp_url="mirrordirector.raspbian.org"  # BASE-URL of RASPBIAN mirror
server=IP                               # IP/FQDN of used  apt-cache-server
port=PORT                               # PORT of used apt-cache-server
release=$(cat /etc/*-release | grep VERSION= | sed -r 's/.{12}//' | sed -r 's/.{2}$//')
distri=$(cat /etc/os-release | grep _NAME= | sed -r 's/.{13}//' | sed -r 's/.{23}$//' | tr '[:upper:]' '[:lower:]')
system=$(cat /etc/os-release | grep _NAME= | sed -r 's/.{13}//' | sed -r 's/.{23}$//' | tr '[:upper:]' '[:lower:]')"-"$(cat /etc/*-release | grep VERSION= | sed -r 's/.{12}//' | sed -r 's/.{2}$//')

# Check whether the defined server is available - source for ping-command: https://stackoverflow.com/questions/8937663/shell-script-to-check-wether-a-server-is-reachable
case $distri in
    "debian" | "raspbian") 
        rm_original_source
        set_new_file $distri
        ;;
    *)
		# Do nothing, as no sources are defined.
		echo "THIS SCRIPT WAS DESIGNED FOR DEBIAN AND RASPBIAN DISTRIBUTIONS ONLY. NOTHING WILL BE CHANGED!"
		;;
esac
exit 0

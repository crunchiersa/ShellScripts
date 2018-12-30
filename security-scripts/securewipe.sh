#!/bin/bash
#20160102--crunchie
# Check if executing User is root, if not --> exit with error!
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
#Inform user about the consequences of this script.
echo -e "This Script is used to securely wipe any connected block device. The device will need to be repartioned after running this script. \nIF YOU DO NOT UNDERSTAND WHAT THIS MEANS, PLEASE DO NOT USE THIS SCRIPT!"
echo -e "Do you want to continue? y/n"
read reply
#Continue only if user entered "yes"
if [ "$reply" != "y" ]; then
	echo -e "The program will now exit!"
	exit 1
fi
#Set variables
status=nok
i=0
j=0
fs=inv
loop=true
# List connected block devices.
echo "The Following devices are connected:"
lsblk
# Ask for user input, input = device to be wiped.
while [ "$status" != "ok" ]
do 
	i=$(( i+1 ))
	echo -e "Please enter which device should be wiped:"
	read device
#Test if device exists. If it exists set status to ok.
	[ -e /dev/"$device" ] && status=ok || status=nok
	if [ "$status" != ok ]; then
#Catch possible wrong entries. If Tries exceeds 5 --> Exit with Error!
		case "$i" in
			1)	echo -e "Device doesn't exist!"
				echo -e "Please try again!"
				echo -e "You have 4 more tries!"
			;;
			2)
				echo -e "Device doesn't exist!"
				echo -e "Please try again!"
				echo -e "You have 3 more tries!"
			;;
			3) 	echo -e "Device doesn't exist!"
				echo -e "Please try again!"
				echo -e "You have 2 more tries!"
			;;
			4)	echo -e "Device doesn't exist!"
				echo -e "Please try again!"
				echo -e "You have 1 more tries!"
			;;
			5)	echo -e "Too many failed attempts. The program will now exit!"
				exit 
		esac
	fi
done
# Verify user entered the correct device.
echo -e "Are you sure you want to wipe the device /dev/"$device"? y/n"
read reply
#Continue only if user entered "yes"
if [ "$reply" != "y" ]; then
	echo -e "The program will now exit!"
	exit 1
fi
# Unmount all connected partitions of the device, errors will not be shown.
umount /dev/$device* 2> /dev/zero
# Wipe the entered device. Device will be overwritten bei random data
# and then filled with 0's.
echo "The device will now be wiped!"
shred -vzn 1 /dev/"$device"
echo "Your device has been wiped!"
exit 0


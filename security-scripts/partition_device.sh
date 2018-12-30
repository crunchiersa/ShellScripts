#!/bin/bash
#20160101--crunchie
# Check if executing User is root, if not --> exit with error!
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# Inform user
echo -e "This script assumes, no partition table exists."
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
			5) 	echo -e "Too many failed attempts. The program will now exit!"
				exit 
		esac
	fi
done
# Verify user entered the correct device.
echo -e "Are you sure you want to partition the device /dev/"$device"? y/n"
read reply
#Continue only if user entered "y"
if [ "$reply" != "y" ]; then
	echo -e "The program will now exit!"
	exit 1
fi
# Unmount all connected partitions of the device, errors will not be shown.
umount /dev/$device* 2> /dev/zero
echo -e "The Device will be partitioned now."
# Keep asking for a valid file system for the partition.
while [ "$loop" = true ]
do
	j=$(( j+1 ))
	echo -e "What file system do you want the partition to be? ext4/ext2/ntfs/vfat(=fat32)"
	read fs
	if [ "$fs" != "ext4" ] | [ "$fs" != "ext2" ] | [ "$fs" != "ntfs" ] | [ "$fs" != "vfat" ]
	then
		case "$j" in
			1)	echo -e "Not a valid file system!"
				echo -e "Please try again!"
				echo -e "You have 4 more tries!"
			;;
			2)	echo -e "Not a valid file system!"
				echo -e "Please try again!"
				echo -e "You have 3 more tries!"
			;;
			3) 	echo -e "Not a valid file system!"
				echo -e "Please try again!"
				echo -e "You have 2 more tries!"
			;;
			4)	echo -e "Not a valid file system!"
				echo -e "Please try again!"
				echo -e "You have 1 more tries!"
			;;
			5) 	echo -e "Too many failed attempts. The program will now exit!"
				exit 
		esac
	fi
	if [ "$fs" = "ext4" ] || [ "$fs" = "ext2" ] || [ "$fs" = "ntfs" ] || [ "$fs" = "vfat" ]
	then
		loop=false
		break 1
	fi
done
# Create gpt partition table.
sudo parted --script /dev/"$device" mklabel gpt
if [ $? -ne 0 ]
then
	echo "Could not create partition table!"
	exit 1
fi
# Create primary partition for 100% of the device.
sudo parted --script /dev/"$device" mkpart primary 0% 100%
sudo mkfs -t "$fs" /dev/"$device"1
exit 0

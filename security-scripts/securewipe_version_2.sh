#!/bin/bash
#2016-01-01-- crunchie
# Check if executing User is root, if not --> exit with error!
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# List connected block devices.
echo "The Following devices are connected:"
lsblk
# Ask for user input, input = device to be wiped.
echo -e "Please enter which device(i.e. sde) should be wiped:"
read device
# Verify user entered the correct device.
echo -e "Is this the really the device you want to wipe? /dev/"$device""
echo -e "Are you sure you wish to continue? yes/no"
read reply
#Continue only if user entered "yes"
if [ "$reply" != "yes" ]; then
   exit
fi
# Unmount all connected partitions of the device, errors will not be shown.
umount /dev/$device* 2> /dev/zero
# Wipe the entered device. Device will be overwritten bei random data
# and then filled with 0's.
echo "The device will now be wiped!"
shred -vzn 1 /dev/"$device"
exit 0

#!/bin/bash
# Check if executing User is root, if not --> exit with error!
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# List connected block devices.
echo "The Following devices are connected:"
lsblk
# Ask for user input, input = device to be wiped.
echo "Please enter which device(i.e. sde) should be wiped:"\n
read device
# Verify user entered the correct device.
echo "Is this the really the device you want to wipe? /dev/"$device""
read -p "Are you sure you wish to continue? yes/no"
if [ "$REPLY" != "yes" ]; then
   exit
fi
# Unmount all connected partitions of the device.
umount /dev/$device*
# Wipe the entered device. Device will be overwritten bei random data
# and then filled with 0's.
echo "The device will now be wiped!"
shred -vzn 1 /dev/"$device"
exit 1

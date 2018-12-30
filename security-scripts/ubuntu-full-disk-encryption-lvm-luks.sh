#!/bin/bash

################################################################################
# Helper for an easier crypt setup with (K)Ubuntu Linux and LUKS/LVM
#
# Tested on the following Ubuntu versions:
# - Ubuntu 9.04 Jaunty (32bit and 64bit)
# - Ubuntu 9.10 Karmic (32bit and 64bit)
# - Ubuntu 10.04 Lucid (32bit and 64bit)
# - Ubuntu 10.10 Maverick (32bit and 64bit)
# - Ubuntu 11.04 Natty (32bit and 64bit)
# - Ubuntu 11.10 Oneiric (32bit and 64bit)
#
# Tested on the following Kubuntu versions:
# - Kubuntu 10.04 Lucid (32bit and 64bit)
# - Kubuntu 11.04 Natty (32bit and 64bit)
#
# I don't have the time to test *every* version out there. Therefore it does not
# mean that this script does not work if your version is not listed above. Just
# try it out and check for an update of this script after a new version of
# (K)Ubuntu is released:
# <http://blog.andreas-haerter.com/2011/06/18/ubuntu-full-disk-encryption-lvm-luks.sh>
#
# Usage:
# 1) Boot a (K)Ubuntu live session
#    ATTENTION: Choose the language you are going to install right from the
#               start! This prevents trouble regarding different keyboard
#               layouts and your entered encryption password!
# 2) Call this script with SUPERUSER privileges (->sudo)
# 3) If you made an error or something like that, REBOOT the Live CD and try it
#    again!
#
#
# LICENSE: This file is open source software (OSS) and may be copied under
#          certain conditions. See the links below for details or try to contact
#          the author(s) of this file in doubt.
#
# @author Andreas Haerter <development@andreas-haerter.com>
# @copyright 2009-2011, Andreas Haerter
# @license GPLv2 (http://www.gnu.org/licenses/gpl2.html)
# @license New/3-clause BSD (http://opensource.org/licenses/bsd-license.php)
# @link http://blog.andreas-haerter.com/2011/06/18/ubuntu-full-disk-encryption-lvm-luks
# @link http://blog.andreas-haerter.com/2011/06/18/ubuntu-festplattenvollverschluesselung-lvm-luks
# @link http://blog.andreas-haerter.com/2011/06/18/ubuntu-full-disk-encryption-lvm-luks.sh
# @link http://andreas-haerter.com
# @version 2011-12-06
################################################################################



################################################################################
# DO NOT TOUCH ANYTHING BELOW THIS LINE WITHOUT KNOWING WHAT YOU ARE DOING!
################################################################################


################################################################################
# Process
################################################################################
URL_ARTICLE="http://blog.andreas-haerter.com/2011/06/18/ubuntu-full-disk-encryption-lvm-luks"

#welcome user
clear
echo "###############################################################################"
echo "# Helper script to install an encrypted (K)Ubuntu Linux (full disk encryption"
echo "# using LUKS/LVM)"
echo "# Found system: $(lsb_release -rs) $(lsb_release -cs)"
echo "#"
echo "# Note: internet connection is mandatory!"
echo "#"
echo "# ATTENTION: THIS SCRIPT MAY ERASE ALL YOUR DATA ON THE CHOSEN DEVICE!"
echo "#            MAKE SURE YOU GOT A BACKUP OF ALL YOUR IMPORTANT DATA OR USE/TRY"
echo "#            AN EMPTY DISK! USE AT YOUR OWN RISK! YOU HAVE BEEN WARNED!"
echo "###############################################################################"


#check: are we root?
if [ $(id -u) -ne 0 ]
then
	echo ""
	echo "Superuser privileges needed. Please call this script using 'sudo'/as root." 1>&2
	exit 1
fi

#article read? start reading now?
echo ""
echo ""
echo "###############################################################################"
echo "# Article read?"
echo "###############################################################################"
echo "Everything is better if you know what you are doing. All important information"
echo "can be found at:"
echo ${URL_ARTICLE}
echo ""
echo -n "Have you read and understand the article? [y|n]: "
read INPUT
if [ ! "${INPUT}" == "y" ] &&
   [ ! "${INPUT}" == "Y" ] &&
   [ ! "${INPUT}" == "j" ] && #German keyboard
   [ ! "${INPUT}" == "J" ]
then
	echo "Starting browser..."
	hash firefox > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo ""
		echo "Firefox error... maybe Kubuntu instead of Ubuntu is running here."
		echo "Let's try to start konqueror or rekonq...."
		echo ""
		hash konqueror > /dev/null 2>&1
		if [ $? -ne 0 ]
		then
			killall rekonq > /dev/null 2>&1 #default since Kubuntu 11.04
			rekonq "${URL_ARTICLE}" > /dev/null 2>&1 &
		else
			killall konqueror > /dev/null 2>&1
			konqueror "${URL_ARTICLE}" > /dev/null 2>&1 &
		fi
	else
		killall firefox-bin > /dev/null 2>&1
		firefox "${URL_ARTICLE}" > /dev/null 2>&1 &
	fi
fi
echo ""
echo "Note: Before all data on your disk will be erased, you will be asked AGAIN."
echo -n "Start work now? [y|n]: "
read INPUT
if [ ! "${INPUT}" == "y" ] &&
   [ ! "${INPUT}" == "Y" ] &&
   [ ! "${INPUT}" == "j" ] && #German keyboard
   [ ! "${INPUT}" == "J" ]
then
	echo "Operation cancelled by user. Recall this script to setup an encrypted system."
	exit 0
fi

#keyboard layout check
echo ""
echo ""
echo "###############################################################################"
echo "# Correct keyboard layout?"
echo "###############################################################################"
echo "Please double check if your keyboard layout is the one you will finally use!"
echo "This is ESSENTIAL because you have to define a password."
echo ""
echo "Example: If you are typing a password containing 'z' or 'y' and you are using a"
echo "         US keyboard layout during this setup but going to install Ubuntu in "
echo "         German, your probably set another password as you may thought,"
echo "         wondering why your password is not working ;-) (hint: on German"
echo "         keyboards 'y' and 'z' are interchanged compared to an U.S. keyboard)"
echo ""
echo "Starting keyboard settings. Please check the 'Layouts' tab."
hash gnome-keyboard-properties > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo ""
	echo "gnome-keyboard-properties error... maybe Kubuntu instead of Ubuntu"
	echo "is running here. Let's try to start the KDE system settings"
	echo ""
	systemsettings > /dev/null 2>&1
else
	gnome-keyboard-properties > /dev/null 2>&1
fi
read -sp "Press [Enter] to continue."
echo ""


echo ""
echo ""
echo "###############################################################################"
echo "# Define your values: target device"
echo "###############################################################################"
echo "Please enter the device we have to use (ALL DATA WILL BE ERASED ON THIS ONE!)"
echo ""
echo "Hints:"
echo "- In common, IDE disk are adressed via '/dev/hd[a-z]' ('/dev/hda'=1st disk,"
echo "  '/dev/hdb'=2nd disk, '/dev/hdc'=3rd disk and so on...)."
echo "- In common, SATA disk are adressed via '/dev/sd[a-z]' ('/dev/sda'=1st disk,"
echo "  '/dev/sdb'=2nd, '/dev/sdc'=3rd disk disk and so on...)."
echo ""
echo -n "Which device should be used? "
read DEVICE_TARGET
DEVICE_TARGET_OK="n"
while [ ! "${DEVICE_TARGET_OK}" == "y" ] &&
      [ ! "${DEVICE_TARGET_OK}" == "Y" ] &&
      [ ! "${DEVICE_TARGET_OK}" == "j" ] && #German keyboard
      [ ! "${DEVICE_TARGET_OK}" == "J" ]
do
	if [ "${DEVICE_TARGET}" != "" ]
	then
		echo -n "You typed '${DEVICE_TARGET}'. Is this correct? [y|n]: "
		read DEVICE_TARGET_OK
	fi
	if [ "${DEVICE_TARGET_OK}" == "y" ] ||
	   [ "${DEVICE_TARGET_OK}" == "Y" ] ||
	   [ "${DEVICE_TARGET_OK}" == "j" ] || #German keyboard
	   [ "${DEVICE_TARGET_OK}" == "J" ]
	then
		break 1
	else
		echo -n "Which device should be used? "
		read DEVICE_TARGET
		continue 1
	fi
done


echo ""
echo ""
echo "###############################################################################"
echo "# Define your values: size of your boot partition (-> '/boot')"
echo "###############################################################################"
echo "Please enter the size you wish to be used for your boot partition '/boot'. This"
echo "partition should be at least 100MB big. 200MB should be enough to be on the"
echo "safe side."
echo "This script defines a minimal value of 50MB for '/boot', everything below will"
echo "not be accepted."
echo "Please enter the size in MB, digits only. (e.g. enter 200 for 200MB)."
echo ""
echo "NOTE: remaining free space (=space not allocated by '/', '/boot' and swap) will"
echo "      be used for '/home'. A summary will be shown after all needed values are"
echo "      defined."
echo ""
echo -n "Size (in MB) of your boot partition '/boot' (200 is recommended)? "
read SIZE_BOOT
SIZE_BOOT_OK="n"
while [ ! "${SIZE_BOOT_OK}" == "y" ] &&
      [ ! "${SIZE_BOOT_OK}" == "Y" ] &&
      [ ! "${SIZE_BOOT_OK}" == "j" ] && #German keyboard
      [ ! "${SIZE_BOOT_OK}" == "J" ]
do
	if [ "${SIZE_BOOT}" != "" ] &&
	   [ ${SIZE_BOOT} -gt 49 ]
	then
		echo -n "You typed '${SIZE_BOOT}'. Is this correct? [y|n]: "
		read SIZE_BOOT_OK
	fi
	if [ "${SIZE_BOOT_OK}" == "y" ] ||
	   [ "${SIZE_BOOT_OK}" == "Y" ] ||
	   [ "${SIZE_BOOT_OK}" == "j" ] || #German keyboard
	   [ "${SIZE_BOOT_OK}" == "J" ]
	then
		break 1
	else
		echo -n "Size (in MB) of your boot partition '/boot' (200 is recommended)? "
		read SIZE_BOOT
		continue 1
	fi
done
unset SIZE_BOOT_OK


echo ""
echo ""
echo "###############################################################################"
echo "# Define your values: size of '/'"
echo "###############################################################################"
echo "Please enter the size you wish to be used for your root partition '/'. This"
echo "partition should be at least 8000M big. 25000M should be enough for nearly"
echo "everybody."
echo "This script defines a minimal value of 2500MB for '/', everything below will"
echo "not be accepted."
echo "Please enter the size in MB, digits only. (e.g. enter 8000 for 8000MB)."
echo ""
echo "NOTE: remaining free space (=space not allocated by '/', '/boot' and swap) will"
echo "      be used for '/home'. A summary will be shown after all needed values are"
echo "      defined."
echo ""
echo -n "Size (in MB) of your root partition '/'? "
read SIZE_ROOT
SIZE_ROOT_OK="n"
while [ ! "${SIZE_ROOT_OK}" == "y" ] &&
      [ ! "${SIZE_ROOT_OK}" == "Y" ] &&
      [ ! "${SIZE_ROOT_OK}" == "j" ] && #German keyboard
      [ ! "${SIZE_ROOT_OK}" == "J" ]
do
	if [ "${SIZE_ROOT}" != "" ] &&
	   [ ${SIZE_ROOT} -gt 2499 ]
	then
		echo -n "You typed '${SIZE_ROOT}'. Is this correct? [y|n]: "
		read SIZE_ROOT_OK
	fi
	if [ "${SIZE_ROOT_OK}" == "y" ] ||
	   [ "${SIZE_ROOT_OK}" == "Y" ] ||
	   [ "${SIZE_ROOT_OK}" == "j" ] || #German keyboard
	   [ "${SIZE_ROOT_OK}" == "J" ]
	then
		break 1
	else
		echo -n "Size (in MB) of your root partition '/'? "
		read SIZE_ROOT
		continue 1
	fi
done
unset SIZE_ROOT_OK


echo ""
echo ""
echo "###############################################################################"
echo "# Define your values: size of swap"
echo "###############################################################################"
echo "Please enter the size you wish to be used for your swap partition. It should"
echo "be 1/3 bigger as your installed RAM to prevent problems using hibernation."
echo "This script defines a minimal value of 256MB for swap, everything below will"
echo "not be accepted."
echo "Please enter the size in MB, digits only (e.g. enter 5200 for 5200MB)."
echo ""
echo "Hints:"
echo "- 1GB RAM  ->  1000MB*1.3 -> 1300MB swap"
echo "- 2GB RAM  ->  2000MB*1.3 -> 2600MB swap"
echo "- 3GB RAM  ->  3000MB*1.3 -> 3900MB swap"
echo "- 4GB RAM  ->  4000MB*1.3 -> 5200MB swap"
echo "- 6GB RAM  ->  6000MB*1.3 -> 7800MB swap"
echo "- 8GB RAM  ->  8000MB*1.3 -> 10400MB swap"
echo "- 10GB RAM -> 10000MB*1.3 -> 13000MB swap"
echo "- 12GB RAM -> 12000MB*1.3 -> 15600MB swap"
echo ""
echo "NOTE: remaining free space (=space not allocated by '/', '/boot' and swap) will"
echo "      be used for '/home'. A summary will be shown after all needed values are"
echo "      defined."
echo ""
echo -n "Size (in MB) of your swap partition? "
read SIZE_SWAP
SIZE_SWAP_OK="n"
while [ ! "${SIZE_SWAP_OK}" == "y" ] &&
      [ ! "${SIZE_SWAP_OK}" == "Y" ] &&
      [ ! "${SIZE_SWAP_OK}" == "j" ] && #German keyboard
      [ ! "${SIZE_SWAP_OK}" == "J" ]
do
	if [ "${SIZE_SWAP}" != "" ] &&
	   [ ${SIZE_SWAP} -gt 255 ]
	then
		echo -n "You typed '${SIZE_SWAP}'. Is this correct? [y|n]: "
		read SIZE_SWAP_OK
	fi
	if [ "${SIZE_SWAP_OK}" == "y" ] ||
	   [ "${SIZE_SWAP_OK}" == "Y" ] ||
	   [ "${SIZE_SWAP_OK}" == "j" ] || #German keyboard
	   [ "${SIZE_SWAP_OK}" == "J" ]
	then
		break 1
	else
		echo -n "Size (in MB) of your swap partition? "
		read SIZE_SWAP
		continue 1
	fi
done
unset SIZE_SWAP_OK


echo ""
echo ""
echo "###############################################################################"
echo "# Encryption strength"
echo "###############################################################################"
echo "Using 'aes-xts-plain' with a key size of 256bit for XTS and AES is recommended"
echo "on newer machines. However, if you got an older PC (single core), a 128bit key"
echo "is the better choice - and is still *very* secure."
echo "Please enter the size in bit, digits only (e.g. enter 256 for 256bit)."
echo ""
echo "Recommended:"
echo "- Single core/slower machine: 128bit"
echo "- Dualcore and above: 256bit"
echo ""
echo -n "XTS/AES key size (128 or 256)? "
read KEYSIZE
KEYSIZE_OK="n"
while [ ! "${KEYSIZE_OK}" == "y" ] &&
      [ ! "${KEYSIZE_OK}" == "Y" ] &&
      [ ! "${KEYSIZE_OK}" == "j" ] && #German keyboard
      [ ! "${KEYSIZE_OK}" == "J" ]
do
	if [ "${KEYSIZE}" == "128" ] ||
	   [ "${KEYSIZE}" == "256" ]
	then
		echo -n "You typed '${KEYSIZE}'. Is this correct? [y|n]: "
		read KEYSIZE_OK
	fi
	if [ "${KEYSIZE_OK}" == "y" ] ||
	   [ "${KEYSIZE_OK}" == "Y" ] ||
	   [ "${KEYSIZE_OK}" == "j" ] || #German keyboard
	   [ "${KEYSIZE_OK}" == "J" ]
	then
		break 1
	else
		echo -n "XTS/AES key size (128 or 256)? "
		read KEYSIZE
		continue 1
	fi
done
unset KEYSIZE_OK


echo ""
echo ""
echo "###############################################################################"
echo "# Start now?"
echo "###############################################################################"
echo "Target device:   ${DEVICE_TARGET}"
echo "Key size:        ${KEYSIZE}bit (for each XTS and AES)"
echo "Size of '/':     ${SIZE_ROOT}MB"
echo "Size of '/boot': ${SIZE_BOOT}MB"
echo "Size of 'swap':  ${SIZE_SWAP}MB"
echo "Size of '/home': 100% of the remaining space not used by '/', '/boot' and swap."
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! ATTENTION: ALL DATA ON '${DEVICE_TARGET}' WILL BE ERASED!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -n "Start work now? [y|n]: "
read INPUT
if [ ! "${INPUT}" == "y" ] &&
   [ ! "${INPUT}" == "Y" ] &&
   [ ! "${INPUT}" == "j" ] && #German keyboard
   [ ! "${INPUT}" == "J" ]
then
	echo "Operation cancelled by user"
	exit 0
fi

echo ""
echo ""
echo "###############################################################################"
echo "# Write random data to '${DEVICE_TARGET}'?"
echo "###############################################################################"
echo "It is recommended to completely fill up your target device with random data"
echo "if it is a common harddisk and was storing unencrypted, personal data until"
echo "now. Additionally, this is a good HDD reliability test for new drives."
echo ""
echo "Note: This may take VERY long (e.g. ~24h for a slower 500GB harddisk using a"
echo "      Celeron M@1.7GHz)."
echo ""
echo -n "Fill '${DEVICE_TARGET}' with random data before encrypting it? [y|n]: "
read INPUT
if [ "${INPUT}" == "y" ] ||
   [ "${INPUT}" == "Y" ] ||
   [ "${INPUT}" == "j" ] || #German keyboard
   [ "${INPUT}" == "J" ]
then
	echo "Start filling up disk with random data... THIS MAY TAKE SEVERAL HOURS!"
	echo ""
	sudo shred -vn 1 ${DEVICE_TARGET}
	if [ $? -ne 0 ]
	then
		echo -e "Filling up disk with random data failed! Please check:\n1) is '${DEVICE_TARGET}' correct? 2) your hardware\nReboot and try it again afterwards!" 1>&2
		exit 1
	fi
	read -sp "Filling up disk with random data done. Press [Enter] to continue."
fi

echo ""
echo ""
echo "###############################################################################"
echo "# LiveCD: Install needed packages and load needed kernel modules"
echo "###############################################################################"
#install needed packages
sudo apt-get install --yes lvm2 cryptsetup
if [ $? -ne 0 ]
then
	echo "Could not install needed packages - please check your internet connection, reboot and try it again!" 1>&2
	exit 1
fi
#load needed kernel modules
sudo modprobe dm-crypt
if [ $? -ne 0 ]
then
	echo "Could not load needed kernel modules?! Please reboot and try it again!" 1>&2
	exit 1
fi
echo "Done."


echo ""
echo ""
echo "###############################################################################"
echo "# Target system: create needed partitions on '${DEVICE_TARGET}'"
echo "###############################################################################"
# Old way using fdisk. Replaced through parted cause fdsik is using a msdos partition
# table with a built-in 2TiB partition limit. parted is able to use GPT and therefore
# you can create partitions >2TiB.
#
# Old code for documentary reasons follows: 
#sudo fdisk ${DEVICE_TARGET} << EOF
#o
#n
#p
#1
#
#+${SIZE_BOOT}M
#n
#p
#2
#
#
#p
#w
#EOF
#if [ $? -ne 0 ]
#then
#	echo "Could not create needed partitions! Please reboot and try it again!" 1>&2
#	exit 1
#fi
sudo parted --script ${DEVICE_TARGET} mklabel gpt
if [ $? -ne 0 ]
then
	echo "Could not create partition label! Please reboot and try it again!" 1>&2
	exit 1
fi
sudo parted --script ${DEVICE_TARGET} mkpart primary 0 ${SIZE_BOOT}
if [ $? -ne 0 ]
then
	echo "Could not create first partition! Please reboot and try it again!" 1>&2
	exit 1
fi
sudo parted --script ${DEVICE_TARGET} mkpart primary ${SIZE_BOOT} 100%
if [ $? -ne 0 ]
then
	echo "Could not create second partition! Please reboot and try it again!" 1>&2
	exit 1
fi
echo "Done."


echo ""
echo ""
echo "###############################################################################"
echo "# Target system: init encryption on '${DEVICE_TARGET}2'"
echo "###############################################################################"
echo "Please follow the instructions..."
echo ""
#XTS is supporting key size of 128 or 256bit. "--key-size 512" means, both
#AES and XTS are using the maximum key size of 256bit. For slower systems
#"--key-size 256" may be an option, resulting in a 128bit encryption.
let LUKSKEYSIZE=${KEYSIZE}+${KEYSIZE}
#using while loops because the user may enter long, complicated passwords...
DO=1
while [ $? -ne 0 ] ||
      [ ${DO} -ne 0 ]
do
	DO=0
	sudo cryptsetup --cipher aes-xts-plain --key-size ${LUKSKEYSIZE} --verify-passphrase luksFormat ${DEVICE_TARGET}2
done
echo "cryptsetup was succesful, crypto-device '${DEVICE_TARGET}2' was created."
echo ""
echo "Unlocking the freshly created crypto-device for the upcoming actions."
echo "Therefore, please type your pwd."
echo ""
DO=1
while [ $? -ne 0 ] ||
      [ ${DO} -ne 0 ]
do
	DO=0
	sudo cryptsetup luksOpen ${DEVICE_TARGET}2 lvm_crypt
done
unset DO
echo ""
echo "Done."


echo ""
echo ""
echo "###############################################################################"
echo "# Target system: setup LVM (Logical Volume Manager) within '${DEVICE_TARGET}2'"
echo "###############################################################################"
sudo pvcreate /dev/mapper/lvm_crypt
if [ $? -ne 0 ]
then
	echo "Could not create physical volume '/dev/mapper/lvm_crypt'! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo vgcreate ubuntu /dev/mapper/lvm_crypt
if [ $? -ne 0 ]
then
	echo "Could not create volume group 'ubuntu'! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo lvcreate -L ${SIZE_SWAP}M -n swap ubuntu
if [ $? -ne 0 ]
then
	echo "Could not create logical volume 'swap' in volume group 'ubuntu'! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo lvcreate -L ${SIZE_ROOT}M -n root ubuntu
if [ $? -ne 0 ]
then
	echo "Could not create logical volume 'root' in volume group 'ubuntu'! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo lvcreate -l 100%FREE -n home ubuntu
if [ $? -ne 0 ]
then
	echo "Could not create logical volume 'home' in volume group 'ubuntu'! Please reboot and try it again!" 1>&2
	exit 1
fi
echo ""
echo "Done."


echo ""
echo ""
echo "###############################################################################"
echo "# Target system: preparing partitions to prevent problems with the installer"
echo "###############################################################################"
echo "NOTE: you can choose other filesystems later. These mkfs calls are just done to"
echo "      prevent problems with the graphical Ubuntu installer."
echo ""
sudo mkswap /dev/mapper/ubuntu-swap
if [ $? -ne 0 ]
then
	echo "Could not create filesystem on '/dev/mapper/ubuntu-swap'! Please reboot and try it again!" 1>&2
	exit 1
fi
sudo mkfs.ext4 /dev/mapper/ubuntu-root
if [ $? -ne 0 ]
then
	echo "Could not create filesystem on '/dev/mapper/ubuntu-root'! Please reboot and try it again!" 1>&2
	exit 1
fi
sudo mkfs.ext4 /dev/mapper/ubuntu-home
if [ $? -ne 0 ]
then
	echo "Could not create filesystem on '/dev/mapper/ubuntu-home'! Please reboot and try it again!" 1>&2
	exit 1
fi
echo ""
echo "Done."


clear
echo "###############################################################################"
echo "# LiveCD: starting the graphical installer"
echo "###############################################################################"
echo "The graphical Ubuntu installer will be launched now. Please follow the"
echo "instructions the installer prints out (but do NOT reboot after installation was"
echo "finished)."
echo ""
echo "You have to choose 'Specify partitions manually (advanced)' and make sure:"
echo "- '${DEVICE_TARGET}1' is attached to the mount point '/boot'"
echo "  and will be formatted as EXT3 (recommended) or EXT2"
echo ""
echo "- '/dev/mapper/ubuntu-root' is attached to the mount point '/'"
echo "  and will be formatted as EXT4 (recommended) or another fs you like"
echo ""
echo "- '/dev/mapper/ubuntu-home' is attached to the mount point '/home'"
echo "  and will be formatted as EXT4 (recommended) or another fs you like"
echo ""
echo "If you need a detailed description with screenshots, have a look at:"
echo ${URL_ARTICLE}
echo ""
echo ""
echo "ATTENTION: DO **NOT REBOOT** AFTER THE INSTALLATION HAS FINISHED! CHOOSE"
echo "           'Continue tryout'!"
read -sp "Press [Enter] to continue."
echo ""
echo ""
echo "Starting the installer 'ubiquity'..."
echo "NOTE: Do NOT close this window/terminal!"
#ubiquity --desktop %k gtk_ui
sh -c 'ubiquity gtk_ui' > /dev/null 2>&1 #command copied from the properties of the GNOME starter on the Live CD's Desktop
if [ $? -ne 0 ]
then
	echo ""
	echo "ubiquity with GNOME UI exited with an error... maybe Kubuntu instead"
	echo "of Ubuntu is running here. Let's try to start ubiquity with KDE interface."
	echo ""
	#ubiquity kde_ui
sh -c 'ubiquity gtk_ui' > /dev/null 2>&1 #command copied from the properties of the KDE starter on the Live CD's Desktop
	if [ $? -ne 0 ]
	then
		echo "Installer exited with an error! Please reboot and try it again!" 1>&2
		exit 1
	fi
fi
echo ""
sleep 2 #give system some time...
echo "Done. Please wait a few seconds..."
sleep 8 #give system some time...


echo ""
echo ""
echo "###############################################################################"
echo "# Target system: post installation actions"
echo "###############################################################################"
echo "Installing the needed software into the freshly installed Ubuntu to get a"
echo "bootable system"
echo ""
echo "NOTE: You can ignore Openpty()- and /etc/crypttab warnings as long as the"
echo "      software was installed."
echo ""
sudo mount /dev/mapper/ubuntu-root /mnt
if [ $? -ne 0 ]
then
	echo "Could not mount: mount /dev/mapper/ubuntu-root /mnt! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo mount ${DEVICE_TARGET}1 /mnt/boot
if [ $? -ne 0 ]
then
	echo "Could not mount: ${DEVICE_TARGET}1 /mnt/boot! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo mount -o bind /dev /mnt/dev
if [ $? -ne 0 ]
then
	echo "Could not mount: mount -o bind /dev /mnt/dev! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo mount -t proc proc /mnt/proc
if [ $? -ne 0 ]
then
	echo "Could not mount: mount -t proc proc /mnt/proc! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo mount -t sysfs sys /mnt/sys
if [ $? -ne 0 ]
then
	echo "Could not mount: mount -t sysfs sys /mnt/sys! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo cp /etc/resolv.conf /mnt/etc/resolv.conf #not everyone got a router...
if [ $? -ne 0 ]
then
	echo "Could not copy /etc/resolv.conf to /mnt/etc/resolv.conf! Please reboot and try it again!" 1>&2
	exit 1
fi

sudo chroot /mnt /bin/bash  << EOF
apt-get install --yes cryptsetup lvm2
echo "lvm_crypt UUID=$(ls -la /dev/disk/by-uuid | grep $(basename ${DEVICE_TARGET}2) | cut -d ' ' -f 9) none luks" >> /etc/crypttab
update-initramfs -u -k all
exit
EOF
if [ $? -ne 0 ]
then
	echo "Something regarding chroot failed! Please reboot and try it again!" 1>&2
	exit 1
fi
echo ""
echo "Success, work done :-)"
read -sp "Press [Enter] to reboot now."
echo ""
sudo reboot
exit 0

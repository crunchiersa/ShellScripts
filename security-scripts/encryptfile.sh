#!/bin/bash
##AUTHOR: crunchie
##DATE: 14.06.2018
##encryptfile.sh - Script to encrypt file, delete the original file afterwards for encrypted storage.
##Version: 1.0

# Define variables; Name of file to be encrypted is passed as parameter $1. passphrase is generated by pwgen --> 200 Characters long, adjust as necessary.
passphrase=`pwgen -Bcns1 200`
filename=$1

if [ ! -f "$filename" ]; then
	echo "No file selected or file does not exist! Program will now abort!"
	exit 1
else 

# Encrypt the passed filename with the generated passphrase. algorythem used = AES-256.
	gpg2 --yes --batch --cipher-algo=AES-256 --passphrase="$passphrase" -c "$filename"
	fileencrypted=$?
		if [ $fileencrypted==0 ]; then
                        echo "File has been encrypted. The password will now be written to a file for safekeeping."
                else
                        echo "Error occurred while encrypting file. Program will now abort!"
                        exit 2
                fi

# Check if file exists to store passphrases with corresponding file.
	if [ ! -f "$HOME"/passphrase.txt ]; then
		touch "$HOME"/passphrase.txt
		echo "File "$HOME"/passphrase.txt created."
	fi

# Write corresponding passphrase for every file  encrypted.
	echo ""$filename"--> "$passphrase"" >> "$HOME"/passphrase.txt
	filewritten=$?

		if [ $filewritten==0 ]; then
			echo "Password written to file "$HOME"/passphrase.txt."
		else
			echo "Error occurred while writing password to file. Program will now abort!"
			exit 3
		fi

# Remove original file after ecryption.
	shred -zun 3 "$filename"
	fileshredded=$?
		if [ $fileshredded==0 ]; then
			echo "Original file has been deleted."
		else
			echo "Error occurred while deleting original file. Program will now abort!"
			exit 4
		fi
fi

exit 0

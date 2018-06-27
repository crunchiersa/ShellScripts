#!/bin/bash
##AUTHOR: crunchie
##DATE: 25.06.2018
##encryptedbackup.sh - Script to encrypt files and copy encrypted files to a remote or local location.
##Version: 1.0

# Array to hold all parameters received from the script call.
files=($*)
arraysize=${#files[@]}
loop=$((arraysize - 1))
i=0
# Fully qualifed path on the remote server
remotelocation="/path/to/target/location/"
# Fully qualified path on the local server
locallocation="/path/to/source/location/"
# ssh-Connection to be used for the backup - ssh-connection needs to be configured for passwordless login - preferable via ssh-config-file
connection="Definition of SSH-Connection"

if [ ! -d $locallocation ]; then
        echo "The Source directory does not exist! Programm will now abort!"
        exit 1
fi

if [ $ssh ==  ]; then
	if [ -d $remotelocation ]; then
		echo ""
	else
		echo "The target directory does not exist. It will now be created."
		mkdir -p $remotelocation
	fi
else
	if [ ssh -t $connection -d $remotelocation ]; then
        	echo ""
	else
        	echo "The remote directory does not exist. It will now be created."
        	ssh $connection mkdir -p $remotelocation
	fi
fi

for i in `seq 0 $loop`; do
        if [ ! -f $locallocation${files[i]} ]; then
	       	echo "File "$locallocation${files[i]}": No file selected or file does not exist!"
		i=$(($i + 1))
	else
		# Encrypt the passed filename with the generated passphrase. algorythem used = AES-256.
		passphrase=`pwgen -Bcns1 200`
        	gpg2 --yes --batch --cipher-algo=AES-256 --passphrase="$passphrase" -c "$locallocation${files[i]}"
        	fileencrypted=$?
                if [ $fileencrypted==0 ]; then
                       	echo "File has been encrypted. The password will now be written to a file for safekeeping."
                else
                       	echo "File "$locallocation${files[i]}":Error occurred while encrypting file."
		fi

		# Check if file exists to store passphrases with corresponding file.
		if [ ! -f "$HOME"/passphrase.txt ]; then
			touch "$HOME"/passphrase.txt
			echo "File created via script, DO NOT ALTER OR DELETE!" >> $HOME/passphrase.txt
			echo "File "$HOME"/passphrase.txt created."
		fi

		# Write corresponding passphrase for every file  encrypted.
		echo ""${files[i]}" --> ""$passphrase" >> $HOME/passphrase.txt
		filewritten=$?

		if [ $filewritten==0 ]; then
			echo "Password written to file "$HOME"/passphrase.txt."
		else
			echo "File "$locallocation"/"${files[i]}": Error occurred while writing password to file."
		fi

		if [ $ssh ==  ]; then
         		rsync -a $locallocation${files[i]}".gpg" $remotelocation
			echo ""$locallocation${files[i]}" has been copied to "$remotelocation"" 
		else
         		rsync -a $locallocation${files[i]}".gpg" $connection":"$remotelocation
			echo ""$locallocation${files[i]}" has been copied to "$remotelocation"" 
		fi

		i=$(($i + 1))
	fi
done
exit 0

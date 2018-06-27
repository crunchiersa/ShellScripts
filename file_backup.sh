#!/bin/bash
##AUTHOR: crunchie
##DATE: 17.06.2018
##file_backup.sh - Copy specified files to back up location 
##Version: 1.0

##Define the variables and initialize them.
# Fully qualifed path on the remote server
remotelocation="/path/to/remote/location"
# Fully qualified path on the local server
locallocation="/path/to/local/location"
# ssh-Connection to be used for the backup - ssh-connection needs to be configured for passwordless login - preferable via ssh-config-file
connection="ssh-connection-specifications"
# Array to hold all parameters received from the script call.
files=($*)
arraysize=${#files[@]}
loop=$((arraysize - 1))
i=0

if [ ! -d $locallocation ]; then
	echo "The Source directory does not exist! Programm will now abort!"
	exit 1
fi

if [ ssh -t $connection -d $remotelocation ]; then
	echo ""
else
	echo "The remote directory does not it exist. It will now be created."
	ssh $connection mkdir -p $remotelocation
fi

# Execute rsync for every file mentioned.
for i in `seq 0 $loop`; do
	rsync -a $locallocation"/"${files[i]} $connection":"$remotelocation
	i=$(($i + 1))
done
exit 0

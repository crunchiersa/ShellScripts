#!/bin/bash

# Generate random password with options to avoid ambigious passwords and use one symbol
# Lenght set to 20 characters and generate one password.
password=`pwgen -By 30 1`

# Print the generated password and copy to clipboard with ability to CTRL+V/CTRL+SHIFT+V Content
printf  $password | xclip -selection c

exit 0

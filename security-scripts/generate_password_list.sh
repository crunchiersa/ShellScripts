#!/bin/bash

# Generate random passwords with options to avoid ambigious passwords and use one symbol
# Lenght set to 20 characters and generate ten password.
# Printing one password per line and writing to a txt-file in home-directory.
pwgen -1By 20 10 > ~/passwords.txt

exit 0

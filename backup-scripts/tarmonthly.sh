#!/bin/bash
#Set Variable month as two digit month of date
month=$(date +%Y-%m)
#Search for files with current month
cd /root
tar -czf "$month"_output.tar.gz "$month"*_output.tar
rm -f "$month"*_output.tar
exit 0
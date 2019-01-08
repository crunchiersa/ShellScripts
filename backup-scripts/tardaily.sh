#!/bin/bash
#Set Variable today as two digit day and month of date
today=$(date +%Y-%m-%d)
#Search for files with current date
cd /root
tar -rf "$today".tar "$today"*_output
rm -f "$today"*_output
exit 0
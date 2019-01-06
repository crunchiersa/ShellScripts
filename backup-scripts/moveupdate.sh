#!/bin/bash
cdate=$(date +%Y-%m-%d_%H_%M_%S)
for file in output; do
mv "$file" "$cdate"_"$file"
done

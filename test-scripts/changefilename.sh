#!/bin/bash
cdate=$(date +%Y-%m-%d_%H-%M-%S)
for file in iptables.firewall.rules; do
cp "$file" "$cdate"_"$file"
done

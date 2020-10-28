#!/bin/bash
# Usage
# ./chkport.sh portnumber
# ./chkport.sh 21
# Defined port number from STDIN
port=$1

netstat -plan|grep :$port|awk '{print $5}'|cut -d: -f 1|sort|uniq -c|sort -nk 1

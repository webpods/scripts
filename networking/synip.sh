#!/bin/bash
netstat -pena|grep SYN_RECV|awk '{print $5}'|awk -F":" '{print $1}'|sort| uniq -c|sort -n


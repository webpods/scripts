#!/bin/bash
sec=$1 $2 $3
shared=$(curl -s -u '<EMAIL>:<KEY>' -F 'secret='$sec'' https://onetimesecret.com/api/v1/share | json_pp|grep secret_key|awk {'print $3'}|sed -e 's/^"//' -e 's/",$//')
echo " --------------------------- "
echo "https://onetimesecret.com/secret/"$shared
echo " --------------------------- "


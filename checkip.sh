#!/bin/bash
#  CheckIP Against  AbuseIPDB

KEY=<KEY>
IP=$1

# Optional Max days, if nothing default to 5
if [ "$2" == "" ]; then
    DAYS=5
else
	DAYS=$2
fi


curl -s -G https://api.abuseipdb.com/api/v2/check \
  --data-urlencode "ipAddress=$IP" \
  -d maxAgeInDays=$DAYS \
  -d verbose \
  -H "Key: $KEY" \
  -H "Accept: application/json" | json_pp

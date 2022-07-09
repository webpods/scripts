#!/bin/bash
# cyber@webpods.com

KEY=<KEY>
DAYS=<DAYS>
IP=$1

curl -s -G https://api.abuseipdb.com/api/v2/check \
  --data-urlencode "ipAddress=$IP" \
  -d maxAgeInDays=7 \
  -d verbose \
  -H "Key: $KEY" \
  -H "Accept: application/json" | json_pp

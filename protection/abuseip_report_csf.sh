#!/usr/bin/sh

# Set your AbuseIPDB API key here.
key=""

# Choose the appropriate AbuseIPDB category ID depending on what LFD is scanning.
# https://www.abuseipdb.com/categories
categories="18,21,14"

# Rename arguments for readability.
ports=$2
inOut=$3
message=$6
logs=$7
trigger=$8

# Concatenate details to form a useful AbuseIPDB comment.
comment="${message}; Ports: ${ports}; Direction: ${inOut}; Trigger: ${trigger}; Logs: ${logs}"

curl https://api.abuseipdb.com/api/v2/report \
  --data-urlencode "ip=$1" \
  -d categories=$categories \
  --data-urlencode "comment=$comment" \
  -H "Key: $key" \
  -H "Accept: application/json"


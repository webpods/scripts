#!/bin/bash
# This tiny thing fetchs 5.5k IPs from AbuseIPDB
# with a confidence rating of 95%+ (very accurate)
# Updates hourly, no IPv6, runs against whitelist
##############

# Maximum amount of IPS - maximum allowed 10k per request
IPBL=5800

# Confidence minimum 0-100(%)
CONFM=95

# APIKEY - Replace with your API KEY
APIKEY=''

# Directory to work in
DIR=/opt/abuseip

# blacklist file
BL=/var/www/html/blacklistv2.txt

# Establish epoch timestamp for current run
TSTAMP=`date +%s`

# Back up old list to epoch back file - Don't remove for failback purposes
cp -pr $DIR/abuseip.txt $DIR/backups/abuseip_$TSTAMP.txt

# Remove the current list
rm -f $DIR/abuseip.txt

# Get new list with our API
curl -G "https://api.abuseipdb.com/api/v2/blacklist?key="$APIKEY"&confidenceMinimum="$CONFM"&plaintext&limit="$IPBL > $DIR/abuseip.txt.tmp

# Take out only the IPv4 addresses
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" $DIR/abuseip.txt.tmp >> $DIR/abuseip.txt

cat $DIR/abuseip.txt > /var/www/html/ipblacklist.txt

# Clean up
rm -f $DIR/abuseip.txt.tmp

# Copy and remove the current blacklist
chmod -x $BL
cp -pr $BL $DIR/backups/blacklistv2_$TSTAMP.txt
rm -f $BL

# Re-run the initial list
#/bin/sh $DIR/ipblacklistv2.sh

## This runs every hour at 0 minutes past
# Runs against our whitelist
#/bin/sh $DIR/edgerouter_blacklist.sh


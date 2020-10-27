#!/bin/bash
CSFBIN=/usr/local/csf/bin


curl -s http://robertsarea.com/scripts/abip.txt > $CSFBIN/abuseipdb_block.pl
chmod +x $CSFBIN/abuseipdb_block.pl
yum -y install perl-JSON
echo 'BLOCK_REPORT = "'$CSFBIN'/abuseipdb_block.pl"' >> /etc/csf/csf.conf
nano -w /etc/csf/csf.conf
perl $CSFBIN/abuseipdb_block.pl

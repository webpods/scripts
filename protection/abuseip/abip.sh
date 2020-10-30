#!/bin/bash
# Shared with others
# Privately
# Meant for CSF BLOCK_REPORT
# Sample deploy
CSFBIN=/usr/local/csf/bin

curl -s http://blacklist.conseevhost.com/abip.txt > $CSFBIN/abuseipdb_block.pl

chmod +x $CSFBIN/abuseipdb_block.pl

yum -y install perl-JSON

echo 'BLOCK_REPORT = "'$CSFBIN'/abuseipdb_block.pl"' >> /etc/csf/csf.conf
nano -w /etc/csf/csf.conf
perl $CSFBIN/abuseipdb_block.pl


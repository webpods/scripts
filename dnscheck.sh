#!/bin/bash
# DNS Checker 1.1.2
# Will need to functionize it

if [ "$1" == "" ]; then
   echo "Usage: ./dnscheck domain.com"
   echo ""
   exit 1
else
	domain=$1
fi

ns=('1.1.1.1')
#ns=('1.1.1.1 8.8.8.8 9.9.9.9 208.67.220.220')
echo "WHOIS Nameservers for $domain"
echo ""
whois --no-recursion $domain|grep -i 'name server'|head -n4|awk {'print $3'}
echo " ---------------------------"
#echo "DNS Checking against Cloudflare, Google, Quad9, OpenDNS"
echo ""
for i in $ns;do echo "Checking $domain against $i";echo "---------------------------";echo "";echo "Name Servers for $domain";echo "---";dig @$i NS $domain +short;echo "---";echo "DNSSEC Check:";echo "";whois --no-recursion $1|grep "DNSSEC"|tr -d ' ';echo "---";echo "CAA records";echo "";dig @$ns CAA $domain +short;echo "---";echo "A record for $domain";echo "";dig @$i A $domain +short;echo "---";echo "MX records for $domain";echo "";dig @$i MX $domain +short;echo "---";echo "MX IPs";echo "---";dig @$ns MX $1 +short|awk {'print $2'}|xargs dig A +short;echo "---";echo "TXT records for $domain

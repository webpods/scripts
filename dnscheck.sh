#!/bin/bash
# DNS Checker .0001
# Will need to functionize it

if [ "$1" == "" ]; then
    echo "Usage: ./dnscheck domain.com"
    echo ""
   exit 1
else
	domain=$1
fi

ns=('1.1.1.1 8.8.8.8 9.9.9.9')
echo "WHOIS Nameservers for $domain"
echo ""
whois $domain|grep -i 'name server'|head -n2|awk {'print $3'}
echo " ---------------------------"
echo "DNS Checking against Cloudflare, Google, Quad9"
echo ""

for i in $ns; do echo "Checking $domain against $i"; echo "---------------------------"; echo ""; echo "Name Servers for $domain"; echo ""; dig @$i NS $domain +short; echo "--";echo "A record for $domain"; echo ""; dig @$i A $domain +short; echo "--"; echo "MX records for $domain"; echo ""; dig @$i MX $domain +short; echo "---"; echo "TXT records for $domain"; dig @$i TXT $domain +short; echo "---------------------------"; echo ""; sleep 1; done


#!/bin/bash
# DNS Checker 1.4
# UsageL ./dnscheck domain.com nameserver
# Ex: ./dnscheck google.com 1.1.1.1
# Will need to functionize it

if [ "$1" == "" ]; then
   echo "Usage: ./dnscheck domain.com 8.8.8.8 <- (optional)"
   echo ""
   exit 1
else
	domain=$1
fi

if [ "$2" == "" ]; then
   ns=('1.1.1.1')
else
	ns=($2)
fi

echo "WHOIS Nameservers for $domain and Dates"
echo ""
whois --no-recursion $domain|grep -i 'name server'|head -n4|awk {'print $3'}
echo " ---------------------------"
whois $domain|egrep "Updated Date|Registry Expiry"|head -n2|tr -d [:blank:]
echo " ---------------------------"
echo ""

for i in $ns;do echo "Checking $domain against $i";echo "---------------------------";echo "";echo "Name Servers for $domain";echo "---";dig @$i NS $domain +short;echo "---";echo "DNSSEC Check:";echo "";whois --no-recursion $1|grep "DNSSEC"|tr -d ' ' ;echo "Analyzer: https://dnssec-analyzer.verisignlabs.com/$domain";echo "---";echo "CAA records";echo "";dig @$ns CAA $domain +short;echo "---";echo "A record for $domain";echo "";dig @$i A $domain +short;echo "---";echo "MX records for $domain";echo "";dig @$i MX $domain +short;echo "---";echo "MX IPs";echo "---";dig @$ns MX $1 +short|awk {'print $2'}|xargs dig A +short;dig @$ns MX $1 +short|awk {'print $2'}|xargs dig AAAA +short;echo "---";echo "TXT records for $domain";echo "";dig @$i TXT $domain +short;dig @$ns TXT default._domainkey.$1 +short; dig @$ns TXT x._domainkey.$1 +short;echo "--";echo "Google DKIM";echo "--";dig @$ns TXT google._domainkey.$1 +short;echo "--";echo "DMARC";echo "---";dig @$ns TXT _dmarc.$1 +short;echo "---------------------------";echo "";done


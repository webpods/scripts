#!/usr/bin/env bash
# Original DFW Blacklist Loader
# Include AbuseIP Project

rm -f /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
touch /var/www/html/blacklist.conseevhost.com/blacklistv2.txt

for ip in $(cat /root/ips.txt); do
  curl --max-time 15 "$ip"/ipblacklist.txt >> /tmp/ipblacklistv2.txt
done

sort /tmp/ipblacklistv2.txt | uniq -c | gawk '$1>=3{print $2}' | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
#curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset | tail -n +35 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/cleantalk_top20.ipset | tail -n +30 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/dshield_top_1000.ipset | tail -n +31 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/stopforumspam_toxic.netset | tail -n +32 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
# Include AbuseIP DB
cat /opt/abuseip/abuseip.txt >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt 
## Cleanup
chmod 777 /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
rm -f /tmp/ipblacklistv2.txt

sed -i '/8.8.8.8/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/8.8.4.4/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/9.9.9.9/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/149.112.112.112/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/209.244.0.3/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/209.244.0.4/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/4.2.2.1/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/4.2.2.2/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/4.2.2.3/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/4.2.2.4/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/4.2.2.5/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/4.2.2.6/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/1.1.1.1/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/1.0.0.1/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/208.67.222.222/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/208.67.220.220/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/104.28.26.44/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/192.243.107.136/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/192.250.224.219/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
sed -i '/98.124.199.115/d' /var/www/html/blacklist.conseevhost.com/blacklistv2.txt





#!/usr/bin/env bash
# Modified blacklist loader to include AbuseIPDB
# Meant to be ran after ipblacklistv2.sh
### Whitelist friendly IPs
pull_bl(){

for ip in $(cat /root/ips.txt); do
  curl --max-time 15 "$ip"/ipblacklist.txt >> /tmp/ipblacklistv2.txt
done

sort /tmp/ipblacklistv2.txt | uniq -c | gawk '$1>=3{print $2}' | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset | tail -n +35 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/cleantalk_top20.ipset | tail -n +30 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/dshield_top_1000.ipset | tail -n +31 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
curl https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/stopforumspam_toxic.netset | tail -n +32 >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
cat /opt/abuseip/abuseip.txt >> /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
}


cidrsort(){
#!/bin/bash
#
# cidr (https://github.com/deadc0de6/cidr) wrapper, v2
# remove IPs matching CIDR range from the blacklist
# 09-01-2020 asmo@conseev

cidr_py=/opt/cidr-py/cidr.py

f_whitelist=/var/www/html/blacklist.conseevhost.com/whitelist.txt
f_blacklist=/var/www/html/blacklist.conseevhost.com/blacklistv2.txt

cp -f ${f_blacklist} ${f_blacklist}.tmp

# make list of CIDR entries
grep "\." ${f_whitelist} >_tmp_whitelist.txt
grep "\." ${f_blacklist} >_tmp_blacklistv2.txt

${cidr_py} 2>&1 intersect --left=${f_blacklist} --right=${f_whitelist} | \
        grep "not found" -v|awk '{print $1}'|cut -d'/' -f1|grep "\." >_tmp_whitelisted.txt

while read -r white_ip; do

        sed -i "/^${white_ip}$/d" ${f_blacklist}.tmp
        echo "removed ${white_ip} from blacklist"

done <_tmp_whitelisted.txt

cat ${f_blacklist}.tmp >${f_blacklist}

rm -f _tmp_blacklistv2.txt _tmp_whitelist.txt _tmp_whitelisted.txt
}

deploy(){
rm -f /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
mv /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
chmod 777 /var/www/html/blacklist.conseevhost.com/blacklistv2.txt
rm -f /tmp/ipblacklistv2.txt
rm -f /var/www/html/blacklist.conseevhost.com/blacklistv2.txt.tmp
}

main(){
	pull_bl "$@"
	cidrsort "$@"
	deploy "$@"
	exit 0
}
  
main "$@"

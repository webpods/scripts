#!/usr/bin/perl
print qq~ 
You are on $sys_hostname
To enable syncookie and close out syn_recv sessions quickly, run the following command
-----------------------------------------
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 45 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_syn_recv
echo 0 > /proc/sys/net/ipv4/tcp_syncookies
-----------------------------------------

This can also be done with sysctl using the -w switch or adding the revalant settings to your /etc/sysctl.conf then loading it with systctl -p /etc/sysctl.conf
~;

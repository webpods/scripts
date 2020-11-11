#!/bin/bash
# Used for Max Performance on Laptop
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag
echo 128 > /proc/sys/vm/nr_hugepages
echo max_performance | tee /sys/class/scsi_host/host*/link_power_management_policy 
echo "write back" | tee /sys/block/sd*/queue/write_cache
#hdparm -W 0 /dev/sdb
#hdparm -W 0 /dev/sdc
/usr/bin/cpufreq-set -c0 -d 3.00GHz
/usr/bin/cpufreq-set -c1 -d 3.00GHz
/usr/bin/cpufreq-set -c2 -d 3.00GHz
/usr/bin/cpufreq-set -c3 -d 3.00GHz

sysctl -p /etc/sysctl.conf

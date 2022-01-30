#!/bin/bash
# KVM Renicer virt-top and vish
# robert@webpods.com

while [[ true ]]
do
        CPUDOM=`virt-top -n 2 --script --stream -o cpu|grep -v -i name|grep -v -i time|grep -v '0.0'|sort -k7 -nr|awk {'print $10'}|head -n1`
        CPUVAL=`virt-top -n 2 --script --stream -o cpu|grep -v -i name|grep -v -i time|grep -v '0.0'|sort -k7 -nr|awk {'print $7'}|head -n1`
        WRITEDOM=`virt-top -n 2 --script --stream -o blockwrrq|grep -v -i name|grep -v -i time|grep -v '0.0'|sort -k4 -nr|awk {'print $10'}|head -n1`
        WRITEDEV=`virsh domblklist $WRITEDOM|tail -n +3|head -n1|awk {'print $1'}`
        WRITEVAL=`virt-top -n 2 --script --stream -o blockwrrq|grep -v -i name|grep -v -i time|grep -v '0.0'|sort -k4 -nr|awk {'print $4'}|head -n1`
        READDOM=`virt-top -n 2 --script --stream -o blockrdrq|grep -v -i name|grep -v -i time|grep -v '0.0'|sort -k3 -nr|awk {'print $10'}|head -n1`
        READDEV=`virsh domblklist $READDOM|tail -n +3|head -n1|awk {'print $1'}`
        READVAL=`virt-top -n 2 --script --stream -o blockrdrq|grep -v -i name|grep -v -i time|grep -v '0.0'|sort -k3 -nr|awk {'print $3'}|head -n1`

clear
echo "Highest CPU KVM guest is $CPUDOM with value $CPUVAL, throttle with: virsh schedinfo $CPUDOM --live cpu_shares=512"
echo "Highest I/O write KVM guest is $WRITEDOM with value $WRITEVAL, throttle with: virsh blkdeviotune $WRITEDOM $WRITEDEV --live --total-iops-sec 200"
echo "Highest I/O read KVM guest is $READDOM with value $READVAL, throttle with: virsh blkdeviotune $READDOM $READDEV --live --total-iops-sec 200"

done

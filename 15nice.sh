#!/bin/bash
# Conseev
# Renice anything -15 to 0 besides killhighload
ps ax -o pid,ni,cmd | grep "\-15" | awk {'print $1'} | xargs renice 0
ps ax -o pid,ni,cmd | grep "\-10" | awk {'print $1'} | xargs renice 0
ps ax -o pid,ni,cmd | grep "\-20" | awk {'print $1'} | xargs renice 0
renice -15 -p `cat /var/run/killhighload`;


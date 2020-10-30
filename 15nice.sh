#!/bin/bash
# Renice anything -15 to 0 besides
ps ax -o pid,ni,cmd | grep "\-15" | awk {'print $1'} | xargs renice 0
ps ax -o pid,ni,cmd | grep "\-10" | awk {'print $1'} | xargs renice 0
ps ax -o pid,ni,cmd | grep "\-20" | awk {'print $1'} | xargs renice 0


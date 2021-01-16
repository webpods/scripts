#!/bin/bash
for i in `cpapi2 --user=CPUSER Park listaddondomains|egrep basedir|awk {'print $2'}`; do  path="/home/mediat40/"$i; echo "WordPress Plug-in Status for $i"; echo "------------";wp --allow-root --path=$path plugin status; echo "------------"; echo ""; done |tee file3.txt

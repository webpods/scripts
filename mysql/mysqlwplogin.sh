#!/bin/bash
# Lazy way
#One liner
mysql -o `grep DB_NAME wp-config.php|awk -F"'" {'print $4'}` -u`grep DB_USER wp-config.php|awk -F"'" {'print $4'}` -p`grep DB_PASS wp-config.php|awk -F"'" {'print $4'}`

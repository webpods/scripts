#!/bin/bash
echo "Finding PHP error_logs then zero them"
find /home*/ -name error_log -type f -print -exec truncate --size 0 "{}" \;

echo "Removing any core dumps"
find /home*/ -type f -regex ".*/core\.[0-9]*$" -exec rm -v {} \;

echo "Remove Old EA Folder"
rm -rfv /home**/cpeasyapache

echo "Removing sold old cPanel User stuff"
for user in `/bin/ls -A /var/cpanel/users` ; do rm -fv /home*/$user/backup-*$user.tar.gz ; done

echo "Removing a bunch of files"
rm -rfv /home*/*/.trash
rm -fv /home*/*/tmp/Cpanel_*
rm -rvf /home*/cpmove-*
rm -rvf /home*/cpanelpkgrestore.TMP*
rm -fv /var/log/*.gz
rm -fv /var/log/*201*
rm -rfv /usr/local/apache.backup*
truncate -s 0 /var/log/apache2/*_log
truncate -s 0 /var/log/apache2/*log
rm -rfv /var/log/apache2/*.gz
truncate -s 0 /var/log/apache2/domlogs/*_log
truncate -s 0 /var/log/apache2/domlogs/*/*_log
rm -rfv /usr/local/apache.backup_archive/*
rm -rfv /usr/local/maldet.bk*
rm -fv /usr/local/maldetect/logs/*
rm -fv /usr/local/cpanel/logs/archive/*.gz
rm -fv /usr/local/apache/logs/*.gz
rm -fv /usr/local/apache/logs/archive/*.gz
service httpd restart
#service cdp-agent restart

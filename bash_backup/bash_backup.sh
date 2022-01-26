#!/bin/bash
# Bash history backup
# by rt
# Nothing complicated
dated=`date +%s`
echo "Backing up Bash"
cp -prv ~/.bash_history ~/bbackup/bash_history-$dated.txt
echo ""
echo "History Copied"
echo "Compressing"
gzip -v -9  ~/bbackup/bash_history-$dated.txt
echo "File Compressed"
echo "Done"


#!/bin/bash
DIR=$HOME/Downloads
CLAM="clamscan --scan-elf=yes --scan-archive=yes -i -r --bytecode=yes --detect-pua=yes  --scan-pdf=yes --alert-broken-media=yes --phishing-sigs=yes --normalize=yes --scan-html=yes --alert-encrypted=yes "
# Get rid of old log file
rm $HOME/virus-scan.log 2> /dev/null

inotifywait -q -m -e close_write,moved_to --format '%w%f' $DIR | while read FILE
do
     # Have to check file length is nonzero otherwise commands may be repeated
     if [ -s $FILE ]; then
          date > $HOME/virus-scan.log
          $CLAM $FILE >> $HOME/virus-scan.log
	  zenity --info --icon-name=browser --ellipsize --text "Virus scan of $FILE\n $(cat $HOME/virus-scan.log)"
     fi
done


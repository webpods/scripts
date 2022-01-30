#!/bin/sh
# Clear memory caches
# Bash Simples - robert@webpods.com
level=$1


if [ -z $1 ] 
	then
		echo "This script clears memory caches - Avoid Level 3"
		echo "Enter a Level between 1-3"

	else
		echo "Sync and Doing Level $level"
		sync; echo $level > /proc/sys/vm/drop_caches
		echo "Done"
	fi


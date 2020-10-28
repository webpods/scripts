#!/bin/bash
# Define temp location
DIR=/opt
# Parse args for program
# Example bash <(curl -s http://robertsarea.com/scripts/hd.sh) -r
ARG1=$1
ARG2=$2

# Download Bin and Make Executable
echo "URL to HDSentinel"
read url

echo "Drive Status by HDSentinel"
echo "Temporarily placing in $DIR"
echo "---------------"


curl -s $url > $DIR/HDSentinel 
chmod +x $DIR/HDSentinel

# Execute Bin
$DIR/HDSentinel $ARG1 $ARG2

# Remove Bin
/bin/rm -rf $DIR/HDSentinel

echo "---------------"

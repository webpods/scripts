#!/bin/bash
# Define temp location
DIR=/root

echo "WP-CLI Portable"
echo "Temporarily placing in $DIR"
echo "---------------"

# Download Bin and Make Executable
curl -s http://robertsarea.com/scripts/wp > $DIR/wp 
chmod +x $DIR/wp

# Execute Bin
$DIR/wp --allow-root

# Remove Bin
/bin/rm -rf $DIR/wp

echo "---------------"

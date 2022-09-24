#!/bin/bash
# Strips the seven digit number for ease of use (can be a complete URL)
# Example:
# ./kiss https://someurl/test/1234567/t/d/

tick=`grep -oP '(?<!\d)\d{7}(?!\d)' <<< $1`
echo "Logging $tick"
echo "---"


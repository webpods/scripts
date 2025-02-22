#!/bin/bash

# Define log directory and ensure it exists
LOG_DIR="/var/log/top_logs"
SECONDS=10
mkdir -p "$LOG_DIR"

while true; do
    # Create a timestamped log file
    LOG_FILE="$LOG_DIR/top_log_$(date +"%Y-%m-%d_%H-%M-%S").log"

    # Run top command in batch mode and log the output
    top -b -n 1 > "$LOG_FILE"
    
    # Wait for x seconds before the next iteration
    sleep $SECONDS
done

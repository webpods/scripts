#!/bin/bash
# cyber@webpods.com
# sysctl tunable to speed up network

echo "Speeds up TCP for Gige"
sysctl -w net.core.rmem_max=8388608
sysctl -w net.core.wmem_max=8388608
sysctl -w net.core.rmem_default=65536
sysctl -w net.core.wmem_default=65536
sysctl -w net.ipv4.tcp_rmem='4096 87380 8388608'
sysctl -w net.ipv4.tcp_wmem='4096 65536 8388608'
sysctl -w net.ipv4.tcp_mem='8388608 8388608 8388608'

# The below can be commeneted out if used in production
sysctl -w net.ipv4.route.flush=1

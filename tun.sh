#!/bin/bash

# Text coloring
yellow='\033[1;33m'
red='\033[1;91m'
nc='\033[0m'

lo=$(ifconfig lo | grep inet | cut -d" " -f10 | head -1)
eth=$(ifconfig eth0 | grep inet | cut -d" " -f10 | head -1)
tun=$(ifconfig tun0 | grep inet | cut -d" " -f10 | head -1)

echo -e "${yellow}Your Loopback IP is:${red} $lo${nc}"
echo -e "${yellow}Your Ethernet IP is:${red} $eth${nc}"
echo -e "${yellow}Your  Tunnel  IP is:${red} $tun${nc}"

exit 1

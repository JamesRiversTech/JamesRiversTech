#!/bin/bash
#COLORS
RED="\033[31m"
RESET="\033[0m"
#######
#FUNCTIONS
function PING () {
        ping -W 0.5 -qc 1 $1 > tmp_$1.txt 2>/dev/null
        var=$(grep -c "1 received" tmp_$1.txt)
        if [ $var -eq 1 ];then
                echo $1
        fi
        rm -f tmp_$1.txt
}

function CTRL_C {
        echo -e "${RED}\nExiting!!!\n${RESET}"
        kill $(jobs -p) 2>/dev/null
        rm -f tmp_*.txt
        exit 0
}
##########
trap CTRL_C SIGINT

# MAIN
ip=$1
if [ -z $1 ];then
        echo -e "${RED}You need to set an ip addr"
        echo -e "EXAMPLE: $0 192.168.0.0${RESET}"
        CTRL_C
fi

ip=$(echo $ip |grep -Eo '([0-9]{1,3}\.){3}')

for i in {1..255};do
        PING "$ip$i" &
done | sort

wait

#!/bin/bash

URL="https://api.maclookup.app/v2/macs/"
#URL="http://0.0.0.0/" # fake vmware url for testing

# Create arrays from arp command
IPs=()
MACs=()

while IFS= read -r line; do
    IP=$(echo "$line" | cut -d"(" -f2 | cut -d')' -f1)
    MAC=$(echo "$line" | awk '{print $4}')
    IPs+=("$IP")
    MACs+=("$MAC")
done < <(arp -a)

len="${#IPs[@]}"
nums=$(( len - 1 ))

echo "=========================================="
echo "Total entries found: $len"
echo "=========================================="

for i in $(seq 0 $nums); do
    IP="${IPs[$i]}"
    MAC="${MACs[$i]}"
    
    # Skip incomplete entries
    if [[ -z "$IP" || -z "$MAC" ]]; then
        continue
    fi
    
    OUT=$(curl -s "${URL}${MAC}/company/name")
    
    # Format output in columns
    printf "%-3s | %-15s | %-17s | %s\n" "$i" "$IP" "$MAC" "$OUT"
done

echo "=========================================="

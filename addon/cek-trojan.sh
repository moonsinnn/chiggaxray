#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)
clear

# Initialize temporary files
> /tmp/other.txt

# Read Trojan user accounts from the configuration file
readarray -t trojan_users < <(grep '^###' /usr/local/etc/xray/trojanwstls.json | awk '{print $2}')

echo "-------------------------------"
echo "-----=[ Trojan User Login ]=-----"
echo "-------------------------------"

# Iterate over each Trojan user account
for user in "${trojan_users[@]}"; do
    # Default to "tidakada" if the user is empty
    [[ -z $user ]] && user="tidakada"

    # Initialize temporary IP tracking file
    > /tmp/iptrojan.txt

    # Get established TCP connections excluding localhost
    readarray -t established_ips < <(netstat -anp | grep ESTABLISHED | grep tcp | grep nginx | awk '{print $5}' | cut -d: -f1 | grep -v 127.0.0.1 | sort -u)

    # Check each established IP against the access log
    for ip in "${established_ips[@]}"; do
        matched_ips=$(grep -w "$user" /var/log/xray/access3.log | awk -v ip="$ip" '$3 ~ ip {print $3}' | cut -d: -f1 | sort -u)

        if [[ $matched_ips == "$ip" ]]; then
            echo "$matched_ips" >> /tmp/iptrojan.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi

        # Remove matched IPs from the other file
        sed -i "/$(cat /tmp/iptrojan.txt)/d" /tmp/other.txt >/dev/null 2>&1
    done

    # Display matched IPs for the user
    if [[ -s /tmp/iptrojan.txt ]]; then
        echo "user : $user"
        nl /tmp/iptrojan.txt
        echo "-------------------------------"
    fi

    # Clean up temporary file
    rm -f /tmp/iptrojan.txt
done

# Display other IPs
echo "other"
sort -u /tmp/other.txt | nl
echo "-------------------------------"

#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)
clear

# Initialize temporary files
> /tmp/other.txt

# Read Vless user accounts from the configuration file
mapfile -t user_accounts < <(grep '^###' /usr/local/etc/xray/vlesswstls.json | cut -d ' ' -f 2)

echo "-------------------------------"
echo "-----=[ Vless User Login ]=-----"
echo "-------------------------------"

# Iterate over each user account
for account in "${user_accounts[@]}"; do
    # Default to "tidakada" if account is empty
    account=${account:-"tidakada"}

    # Initialize temporary file for active IPs
    > /tmp/ipvless.txt

    # Get established TCP connections related to nginx
    mapfile -t active_ips < <(netstat -anp | grep ESTABLISHED | grep tcp | grep nginx | awk '{print $5}' | cut -d: -f1 | grep -v 127.0.0.1 | sort -u)

    # Check each active IP against the user account
    for ip in "${active_ips[@]}"; do
        matched_ips=$(grep -w "$account" /var/log/xray/access2.log | awk -v ip="$ip" '{if ($3 ~ ip) print $3}' | cut -d: -f1 | sort -u)

        if [[ -n $matched_ips ]]; then
            echo "$matched_ips" >> /tmp/ipvless.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi

        # Remove matched IPs from the other IPs list
        sed -i "/$(cat /tmp/ipvless.txt)/d" /tmp/other.txt >/dev/null 2>&1
    done

    # Display user account information
    if [[ -s /tmp/ipvless.txt ]]; then
        echo "user : $account"
        nl /tmp/ipvless.txt
        echo "-------------------------------"
    fi

    # Clean up temporary file
    rm -f /tmp/ipvless.txt
done

# Display other IPs
echo "other"
nl /tmp/other.txt | sort -u
echo "-------------------------------"

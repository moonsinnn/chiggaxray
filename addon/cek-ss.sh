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

# Read Shadowsocks user data
mapfile -t users < <(grep '^###' /usr/local/etc/xray/shadowsocksws.json | awk '{print $2}')

echo "-------------------------------"
echo "-----=[ Shadowsocks User Login ]=-----"
echo "-------------------------------"

# Loop through each user account
for user in "${users[@]}"; do
    user=${user:-"tidakada"}  # Default to "tidakada" if user is empty
    > /tmp/ipshadowsocks.txt  # Clear temporary file for IPs

    # Get established connections
    mapfile -t established_ips < <(netstat -anp | grep ESTABLISHED | grep tcp | grep nginx | awk '{print $5}' | cut -d: -f1 | grep -v 127.0.0.1 | sort -u)

    # Check each established IP against the user
    for ip in "${established_ips[@]}"; do
        matched_ips=$(grep -w "$user" /var/log/xray/access4.log | awk -v ip="$ip" '{if ($3 ~ ip) print $3}' | cut -d: -f1 | sort -u)

        if [[ -n $matched_ips ]]; then
            echo "$matched_ips" >> /tmp/ipshadowsocks.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi

        # Remove matched IPs from other.txt
        sed -i "/$(cat /tmp/ipshadowsocks.txt | tr '\n' '|')/d" /tmp/other.txt >/dev/null 2>&1
    done

    # Display user information
    if [[ -s /tmp/ipshadowsocks.txt ]]; then
        echo "user : $user"
        nl /tmp/ipshadowsocks.txt
        echo "-------------------------------"
    fi

    rm -f /tmp/ipshadowsocks.txt  # Clean up temporary file
done

# Display other IPs
echo "other"
nl /tmp/other.txt | sort -u
echo "-------------------------------"

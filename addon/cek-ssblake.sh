#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Clear the terminal
clear

# Initialize temporary files
> /tmp/other.txt
> /tmp/ipshadowsocks.txt

# Read user accounts from the configuration file
user_accounts=($(grep '^###' /usr/local/etc/xray/ssblakews.json | awk '{print $2}'))

echo "-------------------------------"
echo "-----=[ SS Blake User Login ]=-----"
echo "-------------------------------"

# Process each user account
for account in "${user_accounts[@]}"; do
    # Default to "tidakada" if account is empty
    account=${account:-"tidakada"}

    # Get established IPs from netstat
    established_ips=($(netstat -anp | grep ESTABLISHED | grep tcp | grep nginx | awk '{print $5}' | cut -d: -f1 | grep -v 127.0.0.1 | sort -u))

    # Check each IP against the access log
    for ip in "${established_ips[@]}"; do
        matched_ips=$(grep -w "$account" /var/log/xray/access5.log | awk -v ip="$ip" '$3 ~ ip {print $3}' | cut -d: -f1 | sort -u)

        if [[ -n $matched_ips ]]; then
            echo "$matched_ips" >> /tmp/ipshadowsocks.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi

        # Remove matched IPs from the other file
        sed -i "/$(cat /tmp/ipshadowsocks.txt)/d" /tmp/other.txt >/dev/null 2>&1
    done

    # Display matched IPs for the current account
    if [[ -s /tmp/ipshadowsocks.txt ]]; then
        echo "user : $account"
        nl /tmp/ipshadowsocks.txt
        echo "-------------------------------"
    fi

    # Clean up temporary file
    > /tmp/ipshadowsocks.txt
done

# Display other IPs
echo "other"
nl /tmp/other.txt | sort -u
echo "-------------------------------"

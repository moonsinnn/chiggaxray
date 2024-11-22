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

# Extract Vmess user logins from the configuration file
mapfile -t vmess_users < <(grep '^###' /usr/local/etc/xray/vmesswstls.json | awk '{print $2}')

echo "-------------------------------"
echo "-----=[ Vmess User Login ]=-----"
echo "-------------------------------"

# Iterate through each Vmess user
for user in "${vmess_users[@]}"; do
    user=${user:-"tidakada"}  # Default to "tidakada" if user is empty
    > /tmp/ipvmess.txt  # Clear the temporary IP file

    # Get established TCP connections excluding localhost
    mapfile -t established_ips < <(netstat -anp | grep ESTABLISHED | grep tcp | grep nginx | awk '{print $5}' | cut -d: -f1 | grep -v 127.0.0.1 | sort -u)

    # Check each established IP against the access log
    for ip in "${established_ips[@]}"; do
        matched_ips=$(grep -w "$user" /var/log/xray/access.log | awk -v ip="$ip" '{if ($3 ~ ip) print $3}' | cut -d: -f1 | sort -u)

        if [[ $matched_ips == "$ip" ]]; then
            echo "$matched_ips" >> /tmp/ipvmess.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi

        # Remove matched IPs from the other IPs list
        sed -i "/$(cat /tmp/ipvmess.txt)/d" /tmp/other.txt >/dev/null 2>&1
    done

    # Display matched IPs for the user
    if [[ -s /tmp/ipvmess.txt ]]; then
        echo "user : $user"
        nl /tmp/ipvmess.txt
        echo "-------------------------------"
    fi

    rm -f /tmp/ipvmess.txt  # Clean up temporary file
done

# Display other IPs
echo "other"
nl /tmp/other.txt | sort -u
echo "-------------------------------"

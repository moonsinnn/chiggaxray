#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the current IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Function to handle user expiration
handle_user_expiration() {
    local config_file="$1"
    local service_name="$2"
    
    # Extract user data from the configuration file
    local users=($(grep '^###' "$config_file" | cut -d ' ' -f 2))
    local current_date=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local expiration_date=$(grep -w "^### $user" "$config_file" | cut -d ' ' -f 3)
        local expiration_epoch=$(date -d "$expiration_date" +%s)
        local current_epoch=$(date -d "$current_date" +%s)
        local days_until_expiration=$(((expiration_epoch - current_epoch) / 86400))

        if [[ $days_until_expiration -eq 0 ]]; then
            # Remove user data from the configuration file
            sed -i "/^### $user $expiration_date/,/^},{/d" "$config_file"
            rm -f "/etc/pooke/vmess/${user}-membervmesstls.json" \
                  "/etc/pooke/vmess/${user}-membervmessnontls.json" \
                  "/etc/pooke/vmess/${user}-membervmessgrpc.json"
        fi
    done

    # Restart the associated service
    systemctl restart "$service_name"
}

# Process each protocol
handle_user_expiration "/usr/local/etc/xray/vmesswstls.json" "xray@vmesswstls"
handle_user_expiration "/usr/local/etc/xray/vlesswstls.json" "xray@vlesswstls"
handle_user_expiration "/usr/local/etc/xray/trojanwstls.json" "xray@trojanwstls"
handle_user_expiration "/usr/local/etc/xray/shadowsocksws.json" "xray@shadowsocksws"
handle_user_expiration "/usr/local/etc/xray/ssblakews.json" "xray@ssblakews"

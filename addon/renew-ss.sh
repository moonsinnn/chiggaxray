#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Count the number of existing clients
CLIENT_COUNT=$(grep -c -E "^### " "/usr/local/etc/xray/shadowsocksws.json")

# Check if there are no clients
if [[ ${CLIENT_COUNT} -eq 0 ]]; then
    clear
    echo -e "\nYou have no existing clients!"
    exit 1
fi

# Display existing clients
clear
echo -e "\nSelect the existing client you want to renew"
echo "Press CTRL+C to return"
echo -e "==============================="
grep -E "^### " "/usr/local/etc/xray/shadowsocksws.json" | cut -d ' ' -f 2-3 | nl -s ') '

# Prompt user to select a client
while true; do
    read -rp "Select one client [1-${CLIENT_COUNT}]: " CLIENT_NUMBER
    if [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${CLIENT_COUNT} ]]; then
        break
    fi
done

# Prompt for the number of days to extend
read -p "Expired (days): " EXTENSION_DAYS

# Extract user and expiration date
USER=$(grep -E "^### " "/usr/local/etc/xray/shadowsocksws.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
EXPIRATION_DATE=$(grep -E "^### " "/usr/local/etc/xray/shadowsocksws.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Calculate new expiration date
CURRENT_DATE=$(date +%Y-%m-%d)
EXPIRATION_TIMESTAMP=$(date -d "$EXPIRATION_DATE" +%s)
CURRENT_TIMESTAMP=$(date -d "$CURRENT_DATE" +%s)
DAYS_LEFT=$(((EXPIRATION_TIMESTAMP - CURRENT_TIMESTAMP) / 86400))
NEW_EXPIRATION_DATE=$(date -d "$((DAYS_LEFT + EXTENSION_DAYS)) days" +"%Y-%m-%d")

# Update expiration date in configuration files
sed -i "s/### $USER $EXPIRATION_DATE/### $USER $NEW_EXPIRATION_DATE/g" /usr/local/etc/xray/shadowsocksws.json
sed -i "s/### $USER $EXPIRATION_DATE/### $USER $NEW_EXPIRATION_DATE/g" /usr/local/etc/xray/shadowsocksgrpc.json

# Restart cron service
service cron restart

# Display success message
clear
echo -e "\nShadowsocks successfully renewed!"
echo "==========================="
echo "Client Name : $USER"
echo "Expired On  : $NEW_EXPIRATION_DATE"

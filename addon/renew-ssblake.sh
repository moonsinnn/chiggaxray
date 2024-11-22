#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Clear the terminal
clear

# Count the number of existing clients
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/ssblakews.json")

# Check if there are no clients
if [[ ${NUMBER_OF_CLIENTS} -eq 0 ]]; then
    clear
    echo -e "\nYou have no existing clients!"
    exit 1
fi

# Prompt user to select a client
clear
echo -e "\nSelect the existing client you want to renew"
echo "Press CTRL+C to return"
echo -e "==============================="
grep -E "^### " "/usr/local/etc/xray/ssblakews.json" | cut -d ' ' -f 2-3 | nl -s ') '

# Input validation for client selection
while true; do
    read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    if [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; then
        break
    fi
done

# Input for expiration days
read -p "Expired (days): " EXPIRATION_DAYS

# Extract user and expiration date
USER=$(grep -E "^### " "/usr/local/etc/xray/ssblakews.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
EXPIRATION_DATE=$(grep -E "^### " "/usr/local/etc/xray/ssblakews.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Calculate new expiration date
CURRENT_DATE=$(date +%Y-%m-%d)
EXPIRATION_TIMESTAMP=$(date -d "$EXPIRATION_DATE" +%s)
CURRENT_TIMESTAMP=$(date -d "$CURRENT_DATE" +%s)
DAYS_LEFT=$(((EXPIRATION_TIMESTAMP - CURRENT_TIMESTAMP) / 86400))
NEW_EXPIRATION_DAYS=$((DAYS_LEFT + EXPIRATION_DAYS))
NEW_EXPIRATION_DATE=$(date -d "$NEW_EXPIRATION_DAYS days" +"%Y-%m-%d")

# Update the expiration date in configuration files
sed -i "s/### $USER $EXPIRATION_DATE/### $USER $NEW_EXPIRATION_DATE/g" /usr/local/etc/xray/ssblakews.json
sed -i "s/### $USER $EXPIRATION_DATE/### $USER $NEW_EXPIRATION_DATE/g" /usr/local/etc/xray/ssblakegrpc.json

# Restart cron service
service cron restart

# Display success message
clear
echo -e "\nShadowsocks has been successfully renewed!"
echo "=========================="
echo "Client Name : $USER"
echo "Expired On  : $NEW_EXPIRATION_DATE"

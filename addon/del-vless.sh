#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Clear the terminal screen
clear

# Count the number of existing clients
CLIENT_COUNT=$(grep -c -E "^### " "/usr/local/etc/xray/vlesswstls.json")

# Check if there are no clients
if [[ ${CLIENT_COUNT} -eq 0 ]]; then
    echo -e "${RED}You have no existing clients!${NC}"
    exit 1
fi

# Display existing clients
clear
echo -e "${GREEN}Select the existing client you want to remove${NC}"
echo "Press CTRL+C to return"
echo "==============================="
echo "     No  Expired   User"
grep -E "^### " "/usr/local/etc/xray/vlesswstls.json" | cut -d ' ' -f 2-3 | nl -s ') '

# Prompt user to select a client
while true; do
    read -rp "Select one client [1-${CLIENT_COUNT}]: " CLIENT_NUMBER
    if [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${CLIENT_COUNT} ]]; then
        break
    fi
done

# Extract user and expiration date
USER=$(grep -E "^### " "/usr/local/etc/xray/vlesswstls.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
EXPIRATION=$(grep -E "^### " "/usr/local/etc/xray/vlesswstls.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Remove the client from configuration files
sed -i "/^### $USER $EXPIRATION/,/^},{/d" /usr/local/etc/xray/vlesswstls.json
sed -i "/^### $USER $EXPIRATION/,/^},{/d" /usr/local/etc/xray/vlessgrpc.json

# Remove the user's account file
rm -f "/root/akun/vless/${USER}.txt"

# Restart the services
systemctl restart xray@vlesswstls
systemctl restart xray@vlessgrpc

# Display success message
clear
echo -e "${GREEN}Account successfully deleted${NC}"
echo "========================="
echo "Client Name : $USER"
echo "Expired On  : $EXPIRATION"

#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)
echo "Checking VPS"
clear

# Count the number of existing clients
CLIENT_COUNT=$(grep -c -E "^### " "/usr/local/etc/xray/shadowsocksws.json")

# Check if there are no clients
if [[ ${CLIENT_COUNT} -eq 0 ]]; then
    echo -e "${RED}You have no existing clients!${NC}"
    exit 1
fi

clear
echo ""
echo "Select the existing client you want to remove"
echo "Press CTRL+C to return"
echo "==============================="
echo "     No  Expired   User"

# List existing clients
grep -E "^### " "/usr/local/etc/xray/shadowsocksws.json" | cut -d ' ' -f 2-3 | nl -s ') '

# Prompt user for client selection
while true; do
    read -rp "Select one client [1-${CLIENT_COUNT}]: " CLIENT_NUMBER
    if [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${CLIENT_COUNT} ]]; then
        break
    fi
done

# Extract user and expiration date
USER=$(grep -E "^### " "/usr/local/etc/xray/shadowsocksws.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
EXPIRATION=$(grep -E "^### " "/usr/local/etc/xray/shadowsocksws.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

# Remove client entries from configuration files
sed -i "/^### $USER $EXPIRATION/,/^},{/d" /usr/local/etc/xray/shadowsocksws.json
sed -i "/^### $USER $EXPIRATION/,/^},{/d" /usr/local/etc/xray/shadowsocksgrpc.json

# Remove user file
rm -f "/root/akun/shadowsocks/${USER}.txt"

# Restart services
systemctl restart xray@shadowsocksws
systemctl restart xray@shadowsocksgrpc

# Confirmation message
clear
echo -e "${GREEN}Account successfully deleted!${NC}"
echo "========================="
echo "Client Name : $USER"
echo "Expired On  : $EXPIRATION"

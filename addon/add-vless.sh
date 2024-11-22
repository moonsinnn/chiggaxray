#!/bin/bash

# Color Definitions
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetching Public IP
MY_IP=$(curl -4 -k -sS ip.sb)
clear

# Domain and Port Configuration
DOMAIN=$(cat /etc/pooke/domain)
PORT_TLS="443"
FIX="%26"

# User Input and Validation
while true; do
    read -rp "Enter Username: " USERNAME
    if [[ ! $USERNAME =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "${RED}Invalid username. Please use alphanumeric characters only.${NC}"
        continue
    fi

    CLIENT_EXISTS=$(grep -w "$USERNAME" /usr/local/etc/xray/vlesswstls.json | wc -l)
    if [[ $CLIENT_EXISTS -gt 0 ]]; then
        echo -e "${RED}This username already exists. Please choose another.${NC}"
        exit 1
    fi
    break
done

UUID=$(xray uuid)
read -p "Enter Expiration Days: " EXPIRATION_DAYS
EXPIRATION_DATE=$(date -d "$EXPIRATION_DAYS days" +"%Y-%m-%d")

# Account Creation
{
    echo "### $USERNAME $EXPIRATION_DATE"
    echo "{\"email\": \"$USERNAME\", \"id\": \"$UUID\", \"level\": 0, \"alterId\": 0}"
} >> /usr/local/etc/xray/vlesswstls.json

{
    echo "### $USERNAME $EXPIRATION_DATE"
    echo "{\"email\": \"$USERNAME\", \"id\": \"$UUID\", \"level\": 0}"
} >> /usr/local/etc/xray/vlessgrpc.json

# Generate Links
VLESS_WSTLS="vless://${UUID}@${DOMAIN}:${PORT_TLS}?path=/zxcvless${FIX}security=tls${FIX}encryption=none${FIX}type=ws#${USERNAME}"
VLESS_GRPC="vless://${UUID}@${DOMAIN}:${PORT_TLS}?mode=gun${FIX}security=tls${FIX}encryption=none${FIX}type=grpc${FIX}serviceName=zxcvlessgrpc#${USERNAME}"

# CLI Links
VLESS_WSTLS_CLI="vless://${UUID}@${DOMAIN}:${PORT_TLS}?path=/zxcvless&security=tls&encryption=none&type=ws#${USERNAME}"
VLESS_GRPC_CLI="vless://${UUID}@${DOMAIN}:${PORT_TLS}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=zxcvlessgrpc#${USERNAME}"

# Account Information Display
clear
ACCOUNT_INFO_PATH="/root/akun/vless/$USERNAME.txt"
{
    echo "====== Account Information ======"
    echo "Client: $USERNAME"
    echo "UUID: $UUID"
    echo "Domain: $DOMAIN"
    echo "alterId: 0"
    echo "Expired: $EXPIRATION_DATE"
    echo "====== Path ======="
    echo "=> WS TLS: zxcvless"
    echo "=> GRPC: zxcvlessgrpc"
    echo "====== Clipboard ======="
    echo "=> WS TLS: $VLESS_WSTLS_CLI"
    echo "=> GRPC: $VLESS_GRPC_CLI"
    echo "====== Rules ======="
    echo "=> No Torrent"
    echo "=> No Seeding"
    echo "=> No Illegal Activity"
} | tee -a "$ACCOUNT_INFO_PATH"

# Finish Process
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@vlesswstls
systemctl restart xray@vlessgrpc
clear
echo "Saved Successfully"

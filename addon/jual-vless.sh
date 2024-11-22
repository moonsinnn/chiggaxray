#!/bin/bash

# Color Definitions
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch Public IP
MY_IP=$(curl -4 -k -sS ip.sb)

# Load Domain and Port
DOMAIN=$(cat /etc/pooke/domain)
PORT_TLS="443"

# User Input and Validation
while true; do
    read -rp "Enter Username: " USERNAME
    CLIENT_EXISTS=$(grep -w "$USERNAME" /usr/local/etc/xray/vlesswstls.json | wc -l)

    if [[ $CLIENT_EXISTS -gt 0 ]]; then
        echo -e "${RED}This username already exists. Please choose another.${NC}"
    else
        break
    fi
done

UUID=$(xray uuid)
read -rp "Enter Expiration (days): " EXPIRATION_DAYS
EXPIRATION_DATE=$(date -d "$EXPIRATION_DAYS days" +"%Y-%m-%d")

# Create Account Entries
{
    echo "### $USERNAME $EXPIRATION_DATE"
    echo "{\"email\": \"$USERNAME\", \"id\": \"$UUID\", \"level\": 1, \"alterId\": 0}"
} >> /usr/local/etc/xray/vlesswstls.json

{
    echo "### $USERNAME $EXPIRATION_DATE"
    echo "{\"email\": \"$USERNAME\", \"id\": \"$UUID\", \"level\": 1}"
} >> /usr/local/etc/xray/vlessgrpc.json

# Generate Links
VLESS_WSTLS="vless://$UUID@$DOMAIN:$PORT_TLS?path=zxcvless&security=tls&encryption=none&type=ws#$USERNAME"
VLESS_GRPC="vless://$UUID@$DOMAIN:$PORT_TLS?mode=gun&security=tls&encryption=none&type=grpc&serviceName=zxcvlessgrpc#$USERNAME"

# Clear Screen
clear

# Account Information Output
ACCOUNT_INFO_PATH="/root/akun/vless/$USERNAME.txt"
{
    echo "====== Account Information ======"
    echo "Client: $USERNAME"
    echo "UUID: $UUID"
    echo "Domain: $DOMAIN"
    echo "alterId: 0"
    echo "Expiration: $EXPIRATION_DATE"
    echo "====== Path ======="
    echo "=> WS TLS: zxcvless"
    echo "=> GRPC: zxcvlessgrpc"
    echo "====== Clipboard ======="
    echo "=> WS TLS: $VLESS_WSTLS"
    echo "=> GRPC: $VLESS_GRPC"
    echo "====== Rules ======="
    echo "=> No Torrent"
    echo "=> No Seeding"
    echo "=> No Illegal Activity"
} | tee -a "$ACCOUNT_INFO_PATH"

# Finish
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@vlesswstls
systemctl restart xray@vlessgrpc
clear

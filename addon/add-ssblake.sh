#!/bin/bash

# Color Definitions
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetching Public IP
MY_IP=$(curl -4 -k -sS ip.sb)
clear

# Configuration Variables
DOMAIN=$(cat /etc/pooke/domain)
PORT_TLS="443"
PORT_NON_TLS="80"
FIX="%26"

# Encryption Methods
METHODS=("aes-128-gcm" "aes-256-gcm" "chacha20-ietf-poly1305" "2022-blake3-aes-128-gcm" "2022-blake3-aes-256-gcm" "2022-blake3-chacha20-poly1305")

# User Input Loop
while true; do
    read -rp "Enter Username: " USER
    CLIENT_EXISTS=$(grep -w "$USER" /usr/local/etc/xray/ssblakews.json | wc -l)

    if [[ $CLIENT_EXISTS -eq 0 ]]; then
        break
    else
        echo -e "${RED}This user already exists. Please choose a different name.${NC}"
    fi
done

UUID=$(xray uuid)
GEN_ID=$(openssl rand -base64 16)
SERVER_ID="CXX4y7hOW6XlLygCsx0U1w=="
read -p "Enter Expiration (days): " EXPIRATION_DAYS
EXPIRATION_DATE=$(date -d "$EXPIRATION_DAYS days" +"%Y-%m-%d")

# Create Account
# WebSocket
sed -i "/#memberblakews$/a\\### $USER $EXPIRATION_DATE\\},{\"password\": \"$GEN_ID\", \"email\": \"$USER\"}" /usr/local/etc/xray/ssblakews.json

# gRPC
sed -i "/#memberblakegrpc$/a\\### $USER $EXPIRATION_DATE\\},{\"password\": \"$GEN_ID\", \"email\": \"$USER\"}" /usr/local/etc/xray/ssblakegrpc.json

# Encryption Method
ENCRYPTION_STRING=$(echo -n "${METHODS[3]}:$SERVER_ID:$GEN_ID" | base64 -w0)

# Shadowsocks Links
SS_BLAKE_WS_CLI="ss://$ENCRYPTION_STRING@$DOMAIN:$PORT_TLS?path=%2Fzxcblakews&security=tls&type=ws#$USER"
SS_BLAKE_GRPC_CLI="ss://$ENCRYPTION_STRING@$DOMAIN:$PORT_TLS?mode=gun&security=tls&type=grpc&serviceName=zxcblakegrpc#$USER"

# Telegram Links
SS_BLAKE_WS_TELE="ss://$ENCRYPTION_STRING@$DOMAIN:$PORT_TLS?path=/zxcblakews$FIX&security=tls$FIX&type=ws#$USER"
SS_BLAKE_GRPC_TELE="ss://$ENCRYPTION_STRING@$DOMAIN:$PORT_TLS?mode=gun$FIX&security=tls$FIX&type=grpc$FIX&serviceName=zxcblakegrpc#$USER"

# Cleanup and Display Account Information
clear
ACCOUNT_INFO_PATH="/root/akun/shadowsocksblake/$USER.txt"
{
    echo -e "====== Account Information ======"
    echo -e "Client : $USER"
    echo -e "Domain : $DOMAIN"
    echo -e "Expired : $EXPIRATION_DATE"
    echo -e "====== Path ======="
    echo -e "=> WS TLS : /zxcblakews"
    echo -e "=> GRPC   : zxcblakegrpc"
    echo -e "====== Clipboard ======="
    echo -e "=> WS TLS : $SS_BLAKE_WS_CLI"
    echo -e "=> GRPC   : $SS_BLAKE_GRPC_CLI"
    echo -e "====== Rules ======="
    echo -e "=> No Torrent"
    echo -e "=> No Seeding"
    echo -e "=> No Illegal Activity"
} | tee -a "$ACCOUNT_INFO_PATH"

# Finish
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@ssblakews
systemctl restart xray@ssblakegrpc
clear
echo "Saved Successfully"

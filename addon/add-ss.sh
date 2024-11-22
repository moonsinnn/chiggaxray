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
PORT_NON_TLS="80"
FIX="%26"

# Shadowsocks Encryption Methods
METHODS=("aes-128-gcm" "aes-256-gcm" "chacha20-ietf-poly1305")

# User Input and Validation
while true; do
    read -rp "User: " -e USER
    CLIENT_EXISTS=$(grep -w "$USER" /usr/local/etc/xray/shadowsocksws.json | wc -l)

    if [[ $CLIENT_EXISTS -eq 2 ]]; then
        echo -e "${RED}This user already exists, please choose another name.${NC}"
        exit 1
    elif [[ $USER =~ ^[a-zA-Z0-9_]+$ ]]; then
        break
    fi
done

UUID=$(xray uuid)
read -p "Expiration (days): " EXPIRATION_DAYS
EXPIRATION_DATE=$(date -d "$EXPIRATION_DAYS days" +"%Y-%m-%d")

# Account Creation
for METHOD in "${METHODS[@]}"; do
    sed -i "/#membershadowsocksws$/a\\
### ${USER} ${EXPIRATION_DATE}\\
},{\"password\": \"${UUID}\",\"method\": \"${METHOD}\", \"level\": 0, \"email\": \"${USER}\"" /usr/local/etc/xray/shadowsocksws.json

    sed -i "/#membershadowsocksgrpc$/a\\
### ${USER} ${EXPIRATION_DATE}\\
},{\"password\": \"${UUID}\",\"method\": \"${METHOD}\", \"level\": 0, \"email\": \"${USER}\"" /usr/local/etc/xray/shadowsocksgrpc.json
done

# Encrypt Method
ENCRYPTED=$(echo -n "${METHODS[2]}:${UUID}" | base64 -w0)

# Shadowsocks Links
SHADOWSOCKS_WS_CLI="ss://${ENCRYPTED}@${DOMAIN}:${PORT_TLS}?path=%2Fzxcshadowsocks&security=tls&type=ws#${USER}"
SHADOWSOCKS_GRPC_CLI="ss://${ENCRYPTED}@${DOMAIN}:${PORT_TLS}?mode=gun&security=tls&type=grpc&serviceName=zxcshadowsocksgrpc#${USER}"

# Telegram Links
SHADOWSOCKS_WS_TELE="ss://${ENCRYPTED}@${DOMAIN}:${PORT_TLS}?path=/zxcshadowsocks${FIX}security=tls${FIX}type=ws#${USER}"
SHADOWSOCKS_GRPC_TELE="ss://${ENCRYPTED}@${DOMAIN}:${PORT_TLS}?mode=gun${FIX}security=tls${FIX}type=grpc${FIX}serviceName=zxcshadowsocksgrpc#${USER}"

# Cleanup and Display Account Information
clear
ACCOUNT_INFO_PATH="/root/akun/shadowsocks/${USER}.txt"
{
    echo -e "====== Account Information ======"
    echo -e "Client : ${USER}"
    echo -e "Domain : ${DOMAIN}"
    echo -e "Expired : ${EXPIRATION_DATE}"
    echo -e "====== Path ======="
    echo -e "=> WS TLS : /zxcshadowsocks"
    echo -e "=> GRPC   : zxcshadowsocksgrpc"
    echo -e "====== Clipboard ======="
    echo -e "=> WS TLS : ${SHADOWSOCKS_WS_CLI}"
    echo -e "=> GRPC   : ${SHADOWSOCKS_GRPC_CLI}"
    echo -e "====== Rules ======="
    echo -e "=> No Torrent"
    echo -e "=> No Seeding"
    echo -e "=> No Illegal Activity"
} | tee -a "$ACCOUNT_INFO_PATH"

# Finish
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@shadowsocksws
systemctl restart xray@shadowsocksgrpc
clear
echo "Saved Successfully"

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

# User Input and Validation
while true; do
    read -rp "Enter Username: " USERNAME
    if [[ ! $USERNAME =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "${RED}Invalid username. Please use alphanumeric characters only.${NC}"
        continue
    fi

    CLIENT_EXISTS=$(grep -cw "$USERNAME" /usr/local/etc/xray/vmesswstls.json)
    if [[ $CLIENT_EXISTS -gt 0 ]]; then
        echo -e "${RED}Username already exists. Please choose another.${NC}"
    else
        break
    fi
done

UUID=$(xray uuid)
read -rp "Enter Expiration Days: " EXPIRATION_DAYS
EXPIRATION_DATE=$(date -d "$EXPIRATION_DAYS days" +"%Y-%m-%d")

# Account Creation
for CONFIG in "vmesswstls" "vmesswsnontls" "vmessgrpc"; do
    sed -i "/#member${CONFIG}\$/a\### ${USERNAME} ${EXPIRATION_DATE}\
    },{\"email\": \"${USERNAME}\",\"id\": \"${UUID}\", \"level\": 1, \"alterId\": 0" /usr/local/etc/xray/${CONFIG}.json
done

# Vmess Configuration
declare -A CONFIGS=(
    ["tls"]="$PORT_TLS"
    ["nontls"]="$PORT_NON_TLS"
    ["grpc"]="$PORT_TLS"
)

for PROTOCOL in "${!CONFIGS[@]}"; do
    cat >"/etc/pooke/vmess/${USERNAME}-membervmess${PROTOCOL}.json" <<EOF
{
    "v": "2",
    "ps": "${USERNAME}",
    "add": "${DOMAIN}",
    "port": "${CONFIGS[$PROTOCOL]}",
    "id": "${UUID}",
    "aid": "0",
    "net": "ws",
    "path": "zxcvmess${PROTOCOL}",
    "type": "none",
    "host": "",
    "tls": "${PROTOCOL/tls/tls}"
}
EOF
done

# Generate Vmess Links
for PROTOCOL in "tls" "nontls" "grpc"; do
    VMESS_LINK="vmess://$(base64 -w 0 /etc/pooke/vmess/${USERNAME}-membervmess${PROTOCOL}.json)"
    echo -e "=> ${PROTOCOL^^} : ${VMESS_LINK}" | tee -a "/root/akun/vmess/${USERNAME}.txt"
done

# Account Information
{
    echo -e "====== Account Information ======"
    echo -e "Client : ${USERNAME}"
    echo -e "UUID : ${UUID}"
    echo -e "Domain : ${DOMAIN}"
    echo -e "alterId : 0"
    echo -e "Expired : ${EXPIRATION_DATE}"
    echo -e "====== Paths ======="
    echo -e "=> WS TLS : zxcvmess"
    echo -e "=> NO TLS : zxcvmess"
    echo -e "=> GRPC   : zxcvmessgrpc"
    echo -e "====== Rules ======="
    echo -e "=> No Torrent"
    echo -e "=> No Seeding"
    echo -e "=> No Illegal Activity"
} | tee -a "/root/akun/vmess/${USERNAME}.txt"

# Cleanup and Restart Services
echo -e "${GREEN}The page will close in 5-10 seconds...${NC}"
sleep 12
systemctl restart xray@vmesswstls
systemctl restart xray@vmesswsnontls
systemctl restart xray@vmessgrpc
clear

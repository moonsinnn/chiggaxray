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
        echo -e "${RED}Invalid username. Please use alphanumeric characters and underscores only.${NC}"
        continue
    fi

    CLIENT_EXISTS=$(grep -cw "$USERNAME" /usr/local/etc/xray/vmesswstls.json)
    if [[ $CLIENT_EXISTS -gt 0 ]]; then
        echo -e "${RED}Username already exists. Please choose a different name.${NC}"
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
    },{\"email\": \"${USERNAME}\",\"id\": \"${UUID}\", \"level\": 0, \"alterId\": 0" /usr/local/etc/xray/${CONFIG}.json
done

# Vmess Configuration
declare -A CONFIGS=(
    ["membervmesstls"]="${PORT_TLS} /zxcvmess tls"
    ["membervmessnontls"]="${PORT_NON_TLS} /worryfree none"
    ["membervmessgrpc"]="${PORT_TLS} zxcvmessgrpc tls"
)

for CONFIG in "${!CONFIGS[@]}"; do
    IFS=' ' read -r PORT PATH TLS <<< "${CONFIGS[$CONFIG]}"
    cat >"/etc/pooke/vmess/${USERNAME}-${CONFIG}.json" <<EOF
{
    "v": "2",
    "ps": "${USERNAME}",
    "add": "${DOMAIN}",
    "port": "${PORT}",
    "id": "${UUID}",
    "aid": "0",
    "net": "ws",
    "path": "${PATH}",
    "type": "none",
    "host": "",
    "tls": "${TLS}"
}
EOF
done

# Generate Vmess Links
declare -A VMESS_LINKS
for CONFIG in "${!CONFIGS[@]}"; do
    VMESS_LINKS["$CONFIG"]="vmess://$(base64 -w 0 /etc/pooke/vmess/${USERNAME}-${CONFIG}.json)"
done

# Account Information Display
ACCOUNT_INFO="/root/akun/vmess/${USERNAME}.txt"
{
    echo -e "====== Account Information ======"
    echo -e "Client: ${USERNAME}"
    echo -e "UUID: ${UUID}"
    echo -e "Non-TLS Ports: 80/8080/2086/8880/2052/2082/2095"
    echo -e "Domain: ${DOMAIN}"
    echo -e "alterId: 0"
    echo -e "Expiration: ${EXPIRATION_DATE}"
    echo -e "====== Paths ======="
    echo -e "=> WS TLS: zxcvmess"
    echo -e "=> NO TLS: worryfree"
    echo -e "=> GRPC: zxcvmessgrpc"
    echo -e "====== Clipboard ======="
    for CONFIG in "${!VMESS_LINKS[@]}"; do
        echo -e "=> ${CONFIG}: ${VMESS_LINKS[$CONFIG]}"
    done
    echo -e "====== Rules ======="
    echo -e "=> No Torrent"
    echo -e "=> No Seeding"
    echo -e "=> No Illegal Activity"
} | tee -a "$ACCOUNT_INFO"

# Finish
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@vmesswstls
systemctl restart xray@vmesswsnontls
systemctl restart xray@vmessgrpc
clear
echo "Saved Successfully"

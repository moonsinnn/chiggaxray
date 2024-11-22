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
        echo -e "${RED}Invalid username. Please use alphanumeric characters and underscores only.${NC}"
        continue
    fi

    CLIENT_EXISTS=$(grep -w "$USERNAME" /usr/local/etc/xray/trojanwstls.json | wc -l)
    if [[ $CLIENT_EXISTS -gt 0 ]]; then
        echo -e "${RED}This username already exists. Please choose another.${NC}"
        exit 1
    fi
    break
done

# UUID and Expiration Date
UUID=$(xray uuid)
read -rp "Enter Expiration (days): " EXPIRATION_DAYS
EXPIRATION_DATE=$(date -d "$EXPIRATION_DAYS days" +"%Y-%m-%d")

# Account Creation
for FILE in trojanwstls.json trojangrpc.json trojanwscf.json; do
    sed -i "/#member${FILE%.*}$/a\### $USERNAME $EXPIRATION_DATE\
    },{\"email\": \"$USERNAME\",\"password\": \"$USERNAME\", \"level\": 0" /usr/local/etc/xray/$FILE
done

# Generate Links
generate_link() {
    local protocol="$1"
    local path="$2"
    echo "trojan://${USERNAME}@${DOMAIN}:${PORT_TLS}?path=${path}${FIX}security=tls${FIX}type=${protocol}#${USERNAME}"
}

TROJAN_WS_TLS=$(generate_link "ws" "/zxctrojan")
TROJAN_GRPC=$(generate_link "grpc" "")
TROJAN_WS_CF=$(generate_link "ws" "/zxctrojancf")

# CLI Links
TROJAN_WS_TLS_CLI="trojan://${USERNAME}@${DOMAIN}:${PORT_TLS}?path=/zxctrojan&security=tls&type=ws#${USERNAME}"
TROJAN_GRPC_CLI="trojan://${USERNAME}@${DOMAIN}:${PORT_TLS}?mode=gun&security=tls&type=grpc&serviceName=zxctrojangrpc#${USERNAME}"
TROJAN_WS_CF_CLI="trojan://${USERNAME}@${DOMAIN}:${PORT_TLS}?path=/zxctrojancf&security=tls&type=ws#${USERNAME}"

# Account Information Output
OUTPUT_FILE="/root/akun/trojan/$USERNAME.txt"
{
    echo -e "====== Account Information ======"
    echo -e "Client : $USERNAME"
    echo -e "Domain : $DOMAIN"
    echo -e "Expired : $EXPIRATION_DATE"
    echo -e "====== Paths ======="
    echo -e "=> WS TLS : zxctrojan"
    echo -e "=> GRPC   : zxctrojangrpc"
    echo -e "=> WS CF  : zxctrojancf"
    echo -e "====== Clipboard ======="
    echo -e "=> WS TLS : $TROJAN_WS_TLS_CLI"
    echo -e "=> GRPC   : $TROJAN_GRPC_CLI"
    echo -e "=> WS CF  : $TROJAN_WS_CF_CLI"
    echo -e "====== Rules ======="
    echo -e "=> No Torrent"
    echo -e "=> No Seeding"
    echo -e "=> No Illegal Activity"
} | tee -a "$OUTPUT_FILE"

# Finish
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@trojanwstls
systemctl restart xray@trojangrpc
systemctl restart xray@trojanwscf
clear
echo "Saved Successfully"

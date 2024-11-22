#!/bin/bash

# Define color codes
RED="\e[1;31m"
GREEN="\e[0;32m"
NC="\e[0m"

# Function to fetch and display system status
function display_status() {
    local service_name="$1"
    local service_display_name="$2"
    
    local status="$(systemctl show "${service_name}" --no-page)"
    local status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)

    if [ "${status_text}" == "active" ]; then
        echo -e "${service_display_name} : ${GREEN}Active${NC}"
    else
        echo -e "${service_display_name} : ${RED}Inactive (Error)${NC}"
    fi
}

# Fetch OS information
neofetch

# Get Information
IP_ADDRESS=$(curl -4 -k -sS ip.sb)
DOMAIN=$(cat /etc/pooke/domain)
SERVER=$(curl -s -4 https://ipapi.co/${IP_ADDRESS}/country_name/)
ISP=$(curl -s -4 https://ipapi.co/${IP_ADDRESS}/org/)

# Display fetched information
echo -e "-------------------------------------------------------------"
echo -e "IP ADDRESS      : ${IP_ADDRESS}"
echo -e "DOMAIN          : ${DOMAIN}"
echo -e "SERVER VPS      : ${SERVER}"
echo -e "ISP             : ${ISP}"
echo -e "-------------------------------------------------------------"

# Check and display the status of various services
display_status "xray@vmesswstls" "Vmess WS TLS"
display_status "xray@vmesswsnontls" "Vmess Non TLS"
display_status "xray@vmessgrpc" "Vmess GRPC"
display_status "xray@vlesswstls" "Vless WS TLS"
display_status "xray@vlessgrpc" "Vless GRPC"
display_status "xray@trojanwstls" "Trojan WS TLS"
display_status "xray@trojangrpc" "Trojan GRPC"
display_status "xray@trojanwscf" "Trojan WS CF"
display_status "xray@shadowsocksws" "Shadowsocks WS"
display_status "xray@shadowsocksgrpc" "Shadowsocks GRPC"
display_status "xray@ssblakews" "Shadowsocks 2022 WS"
display_status "xray@ssblakegrpc" "Shadowsocks 2022 GRPC"
display_status "nginx" "Nginx"

#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Clear the terminal screen
clear

# Display the menu options
echo -e "\n======================================\n"
echo -e "    [1] VMESS WS NONTLS Statistics"
echo -e "    [2] VMESS WS TLS Statistics"
echo -e "    [3] VMESS GRPC Statistics"
echo -e "    [4] VLESS WS TLS Statistics"
echo -e "    [5] VLESS GRPC Statistics"
echo -e "    [6] TROJAN WS TLS Statistics"
echo -e "    [7] TROJAN GRPC Statistics"
echo -e "    [8] TROJAN WS CF Statistics"
echo -e "    [9] SHADOWSOCKS WS Statistics"
echo -e "    [10] SHADOWSOCKS GRPC Statistics"
echo -e "    [11] SHADOWSOCKS WS 2022 Statistics"
echo -e "    [12] SHADOWSOCKS GRPC 2022 Statistics"
echo -e "    [x] Exit"
echo -e "\n======================================"

# Prompt user for selection
read -p "    Select From Options [1-12 or x]: " user_selection
echo -e "\n======================================"
sleep 1
clear

# Handle user selection
case $user_selection in
    1) clear; traffic-vmessnontls ;;
    2) clear; traffic-vmesswstls ;;
    3) clear; traffic-vmessgrpc ;;
    4) clear; traffic-vlesswstls ;;
    5) clear; traffic-vlessgrpc ;;
    6) clear; traffic-trojanwstls ;;
    7) clear; traffic-trojangrpc ;;
    8) clear; traffic-trojanwscf ;;
    9) clear; traffic-shadowsocksws ;;
    10) clear; traffic-shadowsocksgrpc ;;
    11) clear; traffic-ssblakews ;;
    12) clear; traffic-ssblakegrpc ;;
    x) exit ;;
    *) echo "Please select a valid option." ;;
esac

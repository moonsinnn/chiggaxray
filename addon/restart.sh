#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Clear the terminal
clear

# Display menu options
echo -e "\n======================================\n"
echo -e "    [1] Restart All Services"
echo -e "    [2] Restart Vmess"
echo -e "    [3] Restart Vless"
echo -e "    [4] Restart Trojan"
echo -e "    [5] Restart Shadowsocks"
echo -e "    [6] Restart Nginx"
echo -e "    [x] Exit\n"
read -p "    Select From Options [1-6 or x]: " user_choice
echo -e "\n======================================"
sleep 1
clear

# Function to restart services
restart_services() {
    local services=("$@")
    for service in "${services[@]}"; do
        systemctl restart "$service"
    done
    echo -e "\n======================================\n"
    echo -e "          Service/s Restarted         \n"
    echo -e "======================================"
}

# Case statement to handle user input
case $user_choice in
    1)
        restart_services \
            xray@vmesswstls \
            xray@vmesswsnontls \
            xray@vmessgrpc \
            xray@vlesswstls \
            xray@vlessgrpc \
            xray@trojanwstls \
            xray@trojangrpc \
            xray@trojanwscf \
            xray@shadowsocksws \
            xray@shadowsocksgrpc \
            xray@ssblakews \
            xray@ssblakegrpc \
            nginx
        ;;
    2)
        restart_services \
            xray@vmesswstls \
            xray@vmesswsnontls \
            xray@vmessgrpc
        ;;
    3)
        restart_services \
            xray@vlesswstls \
            xray@vlessgrpc
        ;;
    4)
        restart_services \
            xray@trojanwstls \
            xray@trojangrpc \
            xray@trojanwscf
        ;;
    5)
        restart_services \
            xray@shadowsocksws \
            xray@shadowsocksgrpc \
            xray@ssblakews \
            xray@ssblakegrpc
        ;;
    6)
        restart_services nginx
        ;;
    x)
        exit
        ;;
    *)
        echo "Please select a valid option."
        ;;
esac

#!/bin/bash

# Define color codes for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Load domain and port configuration
DOMAIN=$(cat /etc/pooke/domain)
PORT_TLS="443"

# Function to read user information
function read_user_info {
    local user
    local client_exists

    until [[ $user =~ ^[a-zA-Z0-9_]+$ && $client_exists -eq 0 ]]; do
        read -rp "User: " -e user
        client_exists=$(grep -w "$user" /usr/local/etc/xray/trojanwstls.json | wc -l)

        if [[ $client_exists -eq 2 ]]; then
            echo -e "\nUser already exists, please choose another name."
            exit 1
        fi
    done

    echo "$user"
}

# Function to create account
function create_account {
    local user="$1"
    local expiration_days="$2"
    local exp_date

    exp_date=$(date -d "$expiration_days days" +"%Y-%m-%d")

    # Append user information to JSON files
    sed -i "/#membertrojanwstls$/a\\### $user $exp_date\\
    },{\"email\": \"$user\",\"password\": \"$user\", \"level\": 1" /usr/local/etc/xray/trojanwstls.json

    sed -i "/#membertrojangrpc$/a\\### $user $exp_date\\
    },{\"email\": \"$user\",\"password\": \"$user\", \"level\": 1" /usr/local/etc/xray/trojangrpc.json

    echo "$exp_date"
}

# Function to generate links
function generate_links {
    local user="$1"
    local domain="$2"
    local port_tls="$3"

    local trojan_ws_tls="trojan://${user}@${domain}:${port_tls}?path=zxctrojan&security=tls&type=ws#${user}"
    local trojan_grpc="trojan://${user}@${domain}:${port_tls}?mode=gun&security=tls&type=grpc&serviceName=zxctrojangrpc#${user}"

    echo "$trojan_ws_tls" "$trojan_grpc"
}

# Function to display account information
function display_account_info {
    local user="$1"
    local domain="$2"
    local exp_date="$3"
    local trojan_ws_tls="$4"
    local trojan_grpc="$5"

    clear
    echo -e "====== Account Information ======" | tee -a /root/akun/trojan/"$user".txt
    echo -e "Client : $user" | tee -a /root/akun/trojan/"$user".txt
    echo -e "Domain : $domain" | tee -a /root/akun/trojan/"$user".txt
    echo -e "Expired : $exp_date" | tee -a /root/akun/trojan/"$user".txt
    echo -e "====== Path =======" | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> WS TLS : zxctrojan" | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> GRPC   : zxctrojangrpc" | tee -a /root/akun/trojan/"$user".txt
    echo -e "====== Clipboard =======" | tee -a /root/akun/trojan/"$user".txt
    echo -e | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> WS TLS : $trojan_ws_tls" | tee -a /root/akun/trojan/"$user".txt
    echo -e | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> GRPC   : $trojan_grpc" | tee -a /root/akun/trojan/"$user".txt
    echo -e | tee -a /root/akun/trojan/"$user".txt
    echo -e "====== Rules =======" | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> No Torrent" | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> No Seeding" | tee -a /root/akun/trojan/"$user".txt
    echo -e "=> No Illegal Activity" | tee -a /root/akun/trojan/"$user".txt
}

# Main script execution
USER=$(read_user_info)
read -p "Expiration (days): " EXPIRATION_DAYS
EXP_DATE=$(create_account "$USER" "$EXPIRATION_DAYS")
LINKS=$(generate_links "$USER" "$DOMAIN" "$PORT_TLS")
IFS=' ' read -r TROJAN_WS_TLS TROJAN_GRPC <<< "$LINKS"

# Display account information
display_account_info "$USER" "$DOMAIN" "$EXP_DATE" "$TROJAN_WS_TLS" "$TROJAN_GRPC"

# Finish
echo -e "The page will close in 5-10 seconds."
sleep 12
systemctl restart xray@trojanwstls
systemctl restart xray@trojangrpc
clear

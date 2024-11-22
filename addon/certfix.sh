#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(curl -4 -k -sS ip.sb)
clear

# PKG
apt update && upgrade
apt install git -y

# Remove Necesarry Files
rm -f /etc/pooke/priv.crt
rm -f /etc/pooke/priv.key
rm -f /etc/pooke/domain
rm -f /root/domain

# Command
echo "Masukan Domain Baru Kamu"
read -p "Hostname / Domain: " host
echo "$host" >>/etc/pooke/domain
echo "$host" >>/root/domain

# ENV
domain=$(cat /root/domain)

# Clone Acme
ufw disable
git clone https://github.com/acmesh-official/acme.sh.git /etc/acme
cd /etc/acme
systemctl stop nginx
systemctl stop xray@vmesswsnontls
chmod +x acme.sh
./acme.sh --set-default-ca --server letsencrypt
./acme.sh --register-account -m zxc@$domain
./acme.sh --issue -d $domain --standalone --server letsencrypt --force
./acme.sh --installcert -d $domain --key-file /etc/pooke/priv.key --fullchain-file /etc/pooke/priv.crt

# Restart Service
rm -f /root/domain
systemctl restart nginx
systemctl restart xray@vmesswsnontls

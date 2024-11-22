#!/bin/bash

# Define color codes
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

# Display system information
echo -e "\n   -------------------------------------------------------------"
cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
freq=$(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo)
tram=$(free -m | awk 'NR==2 {print $2}')
swap=$(free -m | awk 'NR==3 {print $2}')
up=$(uptime | awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }')

# Display the collected information
echo -e "\n   \e[032;1mCPU Model:\e[0m $cname"
echo -e "   \e[032;1mNumber Of Cores:\e[0m $cores"
echo -e "   \e[032;1mCPU Frequency:\e[0m $freq MHz"
echo -e "   \e[032;1mTotal Amount Of RAM:\e[0m $tram MB"
echo -e "   \e[032;1mTotal Memory:\e[0m $swap MB"
echo -e "   \e[032;1mSystem Uptime:\e[0m $up Hours"
echo -e "\n   -------------------------MENU OPTIONS------------------------\n"

# Display menu options without backup and restore
for i in {1..24} 27; do
        case $i in
        1) echo -e "   $i\e[1;33m)\e[m Create Vmess Account" ;;
        2) echo -e "   $i\e[1;33m)\e[m Create Vless Account" ;;
        3) echo -e "   $i\e[1;33m)\e[m Create Trojan Account" ;;
        4) echo -e "   $i\e[1;33m)\e[m Create Shadowsocks Account" ;;
        5) echo -e "   $i\e[1;33m)\e[m Create Shadowsocks 2022 Account" ;;
        6) echo -e "   $i\e[1;33m)\e[m Delete Vmess Account" ;;
        7) echo -e "   $i\e[1;33m)\e[m Delete Vless Account" ;;
        8) echo -e "   $i\e[1;33m)\e[m Delete Trojan Account" ;;
        9) echo -e "   $i\e[1;33m)\e[m Delete Shadowsocks Account" ;;
        10) echo -e "   $i\e[1;33m)\e[m Delete Shadowsocks 2022 Account" ;;
        11) echo -e "   $i\e[1;33m)\e[m Renew Vmess" ;;
        12) echo -e "   $i\e[1;33m)\e[m Renew Vless" ;;
        13) echo -e "   $i\e[1;33m)\e[m Renew Trojan" ;;
        14) echo -e "   $i\e[1;33m)\e[m Renew Shadowsocks" ;;
        15) echo -e "   $i\e[1;33m)\e[m Renew Shadowsocks 2022" ;;
        16) echo -e "   $i\e[1;33m)\e[m Check Vmess" ;;
        17) echo -e "   $i\e[1;33m)\e[m Check Vless" ;;
        18) echo -e "   $i\e[1;33m)\e[m Check Trojan" ;;
        19) echo -e "   $i\e[1;33m)\e[m Check Shadowsocks" ;;
        20) echo -e "   $i\e[1;33m)\e[m Check Shadowsocks 2022" ;;
        21) echo -e "   $i\e[1;33m)\e[m Traffic Menu" ;;
        22) echo -e "   $i\e[1;33m)\e[m Kernel Update + TweakBBR" ;;
        23) echo -e "   $i\e[1;33m)\e[m Reload Xray Service" ;;
        24) echo -e "   $i\e[1;33m)\e[m Change Domain & Certfix" ;;
        27) echo -e "   $i\e[1;33m)\e[m Custom Kernel Powered By XANMOD" ;;
        esac
done

# Read user input
read -p "     Choose an option [1-24 or 27 or x]: " menu

# Execute the selected option
case $menu in
1) add-vmess ;;
2) add-vless ;;
3) add-trojan ;;
4) add-ss ;;
5) add-ssblake ;;
6) del-vmess ;;
7) del-vless ;;
8) del-trojan ;;
9) del-ss ;;
10) del-ssblake ;;
11) renew-vmess ;;
12) renew-vless ;;
13) renew-trojan ;;
14) renew-ss ;;
15) renew-ss ;;
16) cek-vmess ;;
17) cek-vless ;;
18) cek-trojan ;;
19) cek-ss ;;
20) cek-ss ;;
21) menutraffic ;;
22) tweak ;;
23) restart ;;
24) certfix ;;
27) customkernel ;;
x) info ;;
*) echo "Please select a valid command number." ;;
esac

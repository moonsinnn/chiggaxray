#!/bin/bash

# Define color codes
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
NC='\e[0m'

# Function to display system information
display_menu() {
    local options=(
        "1" "Create Vmess Account"
        "2" "Create Vless Account"
        "3" "Create Trojan Account"
        "4" "Create Shadowsocks Account"
        "5" "Create Shadowsocks 2022 Account"
        "6" "Delete Vmess Account"
        "7" "Delete Vless Account"
        "8" "Delete Trojan Account"
        "9" "Delete Shadowsocks Account"
        "10" "Delete Shadowsocks 2022 Account"
        "11" "Renew Vmess"
        "12" "Renew Vless"
        "13" "Renew Trojan"
        "14" "Renew Shadowsocks"
        "15" "Renew Shadowsocks 2022"
        "16" "Check Vmess"
        "17" "Check Vless"
        "18" "Check Trojan"
        "19" "Check Shadowsocks"
        "20" "Check Shadowsocks 2022"
        "21" "Traffic Menu"
        "22" "Kernel Update + TweakBBR"
        "23" "Reload Xray Service"
        "24" "Change Domain & Certfix"
        "25" "Custom Kernel Powered By XANMOD"
    )

    # Adjusting the height and width of the whiptail menu based on terminal size
    local height=$(tput lines)
    local width=$(tput cols)
    local menu_height=$((height - 5))
    local menu_width=$((width - 10))

    choice=$(whiptail --title "Menu Options" --menu "Choose an option:" "$menu_height" "$menu_width" 15 "${options[@]}" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        execute_option "$choice"
    else
        handle_cancel
    fi
}

# Function to handle cancellation
handle_cancel() {
    whiptail --title "Cancelled" --msgbox "You chose Cancel." 8 45
}

# Function to execute the selected option
execute_option() {
    case $1 in
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
        15) renew-ssblake ;;
        16) cek-vmess ;;
        17) cek-vless ;;
        18) cek-trojan ;;
        19) cek-ss ;;
        20) cek-ssblake ;;
        21) menutraffic ;;
        22) tweak ;;
        23) restart ;;
        24) certfix ;;
        25) info ;;
        *) whiptail --title "Error" --msgbox "Please select a valid command number." 8 45 ;;
    esac
}

# Display system information and menu
display_menu

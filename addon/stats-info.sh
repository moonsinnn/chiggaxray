#!/bin/bash

# Color Definitions
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Fetch Public IP
MY_IP=$(curl -4 -k -sS ip.sb)
clear

# Load Configuration
CONFIG_FILE="/etc/pooke/traffic.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo -e "${RED}Configuration file not found.${NC}"
    exit 1
fi

# Define Constants
VNSTATI="/usr/bin/vnstati"
OUTPUT_PATH="/var/www/html/traffic"
FILENAME_PREFIX="vnstat"

# Generate Bandwidth Reports
declare -A REPORTS=(
    ["summary"]="-s"
    ["top-days"]="-m"
    ["five-minutes"]="-5"
    ["hourly"]="-h"
    ["hourly-graph"]="-hg"
    ["daily"]="-d"
    ["monthly"]="-m"
    ["yearly"]="-y"
)

for report in "${!REPORTS[@]}"; do
    ${VNSTATI} ${REPORTS[$report]} -i "$INTERFACE" -o "${OUTPUT_PATH}/${FILENAME_PREFIX}-${report}.png"
done

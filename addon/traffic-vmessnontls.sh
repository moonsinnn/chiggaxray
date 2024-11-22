#!/bin/bash

API_SERVER="127.0.0.1:10081"
XRAY_BIN="/usr/local/bin/xray/xray"

fetch_api_data() {
    local args=""
    if [[ $1 == "reset" ]]; then
        args="reset: true"
    fi
    $XRAY_BIN api statsquery --server="$API_SERVER" "$args" | 
    awk '{
        if (match($1, /"name":/)) {
            found=1; 
            gsub(/^"|link"|,$/, "", $2);
            split($2, parts, ">>>");
            printf "%s:%s->%s\t", parts[1], parts[2], parts[4];
        } else if (match($1, /"value":/) && found) { 
            found = 0; 
            printf "%.0f\n", $2; 
        } else if (match($0, /}/) && found) { 
            found = 0; 
            print 0; 
        }
    }'
}

calculate_sum() {
    local data="$1"
    local prefix="$2"
    local sorted_data
    sorted_data=$(echo "$data" | grep "^${prefix}" | sort -r)
    
    local sum_output
    sum_output=$(echo "$sorted_data" | awk '
        /->up/{up_sum+=$2}
        /->down/{down_sum+=$2}
        END {
            printf "SUM->up:\t%.0f\nSUM->down:\t%.0f\nSUM->TOTAL:\t%.0f\n", up_sum, down_sum, up_sum + down_sum;
        }'
    )
    
    echo -e "${sorted_data}\n${sum_output}" | 
    numfmt --field=2 --suffix=B --to=iec | 
    column -t
}

data=$(fetch_api_data "$1")
echo "-----------Inbound-----------"
calculate_sum "$data" "inbound"
echo "-----------------------------"
echo "-----------Outbound----------"
calculate_sum "$data" "outbound"
echo "-----------------------------"
echo
echo "-------------User------------"
calculate_sum "$data" "user"

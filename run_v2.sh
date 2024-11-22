#!/bin/bash

# Ensure the script is run as root
if [ "${EUID}" -ne 0 ]; then
    echo -e "Please run as \e[1;31mROOT\e[0m user\e[1;31m!\e[0m"
    exit 1
fi

# Define color codes
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the public IP address
MY_IP=$(curl -4 -k -sS ip.sb)

# Clean up previous configurations
rm -rf /etc/pooke /root/akun/*

# Create necessary directories
mkdir -p /etc/pooke/vmess /root/akun/{vmess,vless,trojan,shadowsocks,shadowsocksblake}
touch /root/domain

# Prompt for domain input
echo -e "${GREEN}Please enter the domain that has been pointed for v2ray service to work${NC}"
read -p "Hostname / Domain: " HOST
echo "$HOST" | tee /etc/pooke/domain /root/domain > /dev/null

# Set up environment variables
SOURCE="https://raw.githubusercontent.com/moonsinnn/chiggaxray/refs/heads/master"
SCGEO="https://raw.githubusercontent.com/malikshi/v2ray-rules-dat/release"
DOMAIN=$(cat /root/domain)

# Install required packages
echo -n -e "${GREEN}Installing packages...${NC}"
apt -y install wget curl jq shc screenfetch >/dev/null 2>&1
echo -e "${GREEN}...Done${NC}"

# Set timezone to GMT +7
echo -n -e "${GREEN}Setting timezone to GMT +7...${NC}"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime >/dev/null 2>&1
echo -e "${GREEN}...Done${NC}"

# Modify SSH configuration
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config >/dev/null 2>&1

# Create systemd service for rc.local
cat >/etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
END

# Create rc.local file
cat >/etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Set permissions for rc.local
chmod +x /etc/rc.local

# Enable and start rc.local service
systemctl enable rc-local
systemctl start rc-local.service

# Fix missing packages
echo -n -e "${GREEN}Fixing missing packages...${NC}"
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip curl nano sed gnupg bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof >/dev/null 2>&1
echo -e "${GREEN}...Fixed${NC}"

# Install Nginx
echo -n -e "${GREEN}Installing Nginx...${NC}"
apt -y install nginx >/dev/null 2>&1
echo -e "${GREEN}...Nginx configured${NC}"
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default >/dev/null 2>&1
wget -q -O /etc/nginx/conf.d/zxc.conf "${SOURCE}/zxc.conf"
systemctl start nginx >/dev/null 2>&1

# Install XRAY Core
echo -n -e "${GREEN}Preparing to install XRAY CORE...${NC}"
apt install curl socat xz-utils wget apt-transport-https gnupg dnsutils lsb-release -y >/dev/null 2>&1
ntpdate pool.ntp.org >/dev/null 2>&1
apt -y install chrony >/dev/null 2>&1
timedatectl set-ntp true >/dev/null 2>&1
systemctl enable chronyd && systemctl restart chronyd >/dev/null 2>&1
timedatectl set-timezone Asia/Jakarta >/dev/null 2>&1

# Install Xray Core
echo -n -e "${GREEN}Installing XRAY CORE...${NC}"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
echo -e "${GREEN}...Latest version installed${NC}"

# Disable Apache2 server if running
systemctl stop apache2 >/dev/null 2>&1
systemctl disable apache2 >/dev/null 2>&1
apt remove apache2 -y >/dev/null 2>&1

# Install SSL certificate
curl https://get.acme.sh | sh
ufw disable >/dev/null 2>&1
systemctl stop nginx
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --register-account -m zxc@"$DOMAIN"
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone --server letsencrypt
~/.acme.sh/acme.sh --installcert -d "$DOMAIN" --key-file /etc/pooke/priv.key --fullchain-file /etc/pooke/priv.crt
# Int config xray
sleep 2
bash -c "$(curl -L $SOURCE/config.sh)"

# Enable XRAY services
for service in vmesswstls vmesswsnontls vmessgrpc vlesswstls vlessgrpc trojanwstls trojangrpc trojanwscf shadowsocksws shadowsocksgrpc ssblakews ssblakegrpc; do
    systemctl enable "xray@$service" >/dev/null 2>&1
    systemctl restart "xray@$service" >/dev/null 2>&1
done

# Download geodata
cd /usr/local/share/xray
rm -rf geosite.dat geoip.dat
wget -q -O geosite.dat "${SCGEO}/geosite.dat"
wget -q -O geoip.dat "${SCGEO}/geoip.dat"

# Get traffic configuration
cd /etc/pooke
rm -f traffic.conf
wget -q -O traffic.conf "${SOURCE}/traffic.conf"

# Get HTML files
cd /var/www/html
rm -f index.html
wget -q -O www.zip "${SOURCE}/www.zip"
unzip -qq www.zip
rm -f www.zip

# Define an array of script names
declare -a SCRIPTS=(
    "add-vmess" "add-vless" "add-trojan" "add-ss" "add-ssblake"
    "jual-vmess" "jual-vless" "jual-trojan" "cek-vmess" "cek-vless"
    "cek-trojan" "cek-ss" "cek-ssblake" "del-vmess" "del-vless"
    "del-trojan" "del-ss" "del-ssblake" "renew-vmess" "renew-vless"
    "renew-trojan" "renew-ss" "renew-ssblake" "menu" "tweak"
    "restart" "xp" "clear-log" "cut-log" "info"
    "customkernel" "badvpn-udpgw" "menutraffic" "certfix" "stats-info"
    "traffic-vmessnontls" "traffic-vmesswstls" "traffic-vmessgrpc"
    "traffic-vlesswstls" "traffic-vlessgrpc" "traffic-trojanwstls"
    "traffic-trojangrpc" "traffic-trojanwscf" "traffic-shadowsocksws"
    "traffic-shadowsocksgrpc" "traffic-ssblakews" "traffic-ssblakegrpc"
)

# Download scripts
cd /usr/bin
for script in "${SCRIPTS[@]}"; do
    wget -q -O "$script" "${SOURCE}/$script.sh"
done

# Set permissions for scripts
echo -n -e "${GREEN}Setting permissions...${NC}"
for script in "${SCRIPTS[@]}"; do
    chmod +x "$script"
done
echo -e "${GREEN}...Done${NC}"

# Clean up
cd
mv /root/domain /etc/pooke/domain

# Install WARP & UDPGW
echo -n -e "${GREEN}Installing WARP & UDPGW...${NC}"
bash <(curl -L git.io/warp.sh) s5 >/dev/null 2>&1
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
echo -e "${GREEN}...Activated${NC}"

# Install VNSTAT
echo -n -e "${GREEN}Installing VNSTAT Monitor...${NC}"
apt -y install vnstat vnstati >/dev/null 2>&1
echo -e "${GREEN}...Success${NC}"

# Clean history
rm -rf ~/.bash_history
history -c && history -w

# Reboot logic
if ! grep -q HISTFILE /etc/profile; then
    echo "unset HISTFILE" >>/etc/profile
    echo "0 5 * * * root clear-log && reboot" >>/etc/crontab
    echo "0 0 * * * root xp" >>/etc/crontab
    echo "*/5 * * * * root stats-info" >>/etc/crontab
    echo "*/10 * * * * root cut-log" >>/etc/crontab
    echo "clear" >>.profile
    echo "info" >>.profile
    echo -e "${GREEN}Rebooting Now${NC}"
else
    echo -e "${GREEN}Rebooting Now${NC}"
fi
reboot

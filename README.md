# linux_ap
How to make an access point out of linux

# Check if interface supports AP mode
iw list | grep "AP"

# Install required packages
sudo apt install hostapd dnsmasq net-tools iptables

# Configure static ip for the AP interface
sudo ip link add name br0 type bridge
sudo ip link set br0 up
sudo ip addr add 192.168.1.1/24 dev br0

# Configure hostapd
sudo nano /etc/hostapd/hostapd.conf

# Add
interface=wlan0
bridge=br0
driver=nl80211
ssid=MyUbuntuAP
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=SecurePass123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# Start hostapd
sudo hostapd -B /etc/hostapd/hostapd.conf

# Configure DHCP and DNS
sudo nano /etc/dnsmasq.conf

# Add
interface=br0
dhcp-range=192.168.10.100,192.168.10.200,255.255.255.0,24h
dhcp-option=3,192.168.10.1
dhcp-option=6,192.168.10.1
server=8.8.8.8

# Start dnsmasq
sudo systemctl restart dnsmasq

# Enable IP Forwarding
sudo sysctl net.ipv4.ip_forward=1
# linux_ap
How to make an access point out of linux

## Check if interface supports AP mode
iw list | grep "AP"

## Install required packages
sudo apt install hostapd dnsmasq net-tools iptables

## Configure static ip for the AP interface
sudo ip link add name br0 type bridge
sudo ip link set br0 up
sudo ip addr add 192.168.1.1/24 dev br0

## Configure hostapd
sudo nano /etc/hostapd/hostapd.conf

## Add
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

## For 5 GHz, change hw_mode=a and pick a DFS-free channel like 36
sudo systemctl unmask hostapd
sudo systemctl enable --now hostapd

## Start hostapd
sudo hostapd -B /etc/hostapd/hostapd.conf

## Configure DHCP and DNS
sudo nano /etc/dnsmasq.conf

## Add
interface=br0
dhcp-range=192.168.10.100,192.168.10.200,255.255.255.0,24h
dhcp-option=3,192.168.10.1
dhcp-option=6,192.168.10.1
server=8.8.8.8
listen-address=127.0.0.1,192.168.1.1
bind-interfaces

## Start dnsmasq
sudo systemctl restart dnsmasq

## Enable IP Forwarding
sudo sysctl net.ipv4.ip_forward=1

## Autostart on boot
sudo systemctl enable --now hostapd dnsmasq

## Enable NAT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

## Make NAT persistent
sudo apt install iptables-persistent
sudo netfilter-persistent save


# Troubleshooting
## dnsmasq can fail to start, this can happen if another service is 
listening on the same port 53
sudo netstat -tulpn | grep 53
# If systemd-resolved is listening on port 53
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl restart dnsmasq
#!/bin/bash
sudo ip addr add 192.168.1.1/24 dev br0
sudo ip link set dev wlan0 master br0
sudo ip link set dev br0 up
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo systemctl start hostapd
sudo systemctl start dnsmasq

# sudo ip addr add 192.168.0.1/24 dev enp3s0
# sudo ip link set dev enp3s0 up
# sudo iptables -t nat -A POSTROUTING -o wlp2s0 -j MASQUERADE
# sudo iptables -A FOWARD -i enp3s0 -o wlp2s0 -j ACCEPT
# sudo iptables -A FORWARD -i wlp2s0 -o enp3s0 -m state --state RELATED,ESTABLISHED -j ACCEPT

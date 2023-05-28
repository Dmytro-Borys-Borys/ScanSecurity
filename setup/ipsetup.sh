#!/bin/bash

# Define the new configuration for wlan0
new_config="auto wlan0
iface wlan0 inet static
    address 172.30.255.254
    netmask 255.255.0.0"

# Remove existing wlan0 lines from /etc/network/interfaces
sudo sed -n -i -e '/^auto wlan0/,/^$/d' /etc/network/interfaces

# Append the new configuration to /etc/network/interfaces
echo "$new_config" | sudo tee -a /etc/network/interfaces > /dev/null
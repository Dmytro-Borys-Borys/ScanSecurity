#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

if command -v dnsmasq &> /dev/null; then
    echo "dnsmasq is installed"
else
    echo "dnsmasq is not installed"
    
    # Instalando dnsmasq
    sudo apt install dnsmasq -y 
fi

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"


# Define the template for nodogsplash.conf
template="interface=$AP_INTERFACE
domain-needed
bogus-priv
bind-interfaces
dhcp-range=$AP_DHCP_RANGE,$AP_NETMASK,12h
dhcp-option=3,$AP_IP
dhcp-option=6,$WAN_DNS"



config_file="$SCRIPT_DIR/dnsmasq.conf"
delete_if_exists "$config_file"
write_template_to_file "$template" "$config_file"
create_symbolic_link "$config_file" "/etc/dnsmasq.conf" "root"


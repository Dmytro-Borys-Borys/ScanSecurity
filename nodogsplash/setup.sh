#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Comprobar si nodogsplash se encuentra instalado
if command -v nodogsplash &> /dev/null; then
    echo "nodogsplash is installed"
else
    echo "nodogsplash is not installed"
    # Instalando requisitos previos nodogsplash
    sudo apt update
    sudo apt install build-essential debhelper devscripts git libmicrohttpd-dev -y

    nds_dir="$BASE_DIR/ignores/nodogsplash"
    
    delete_if_exists $nds_dir

    # Instalando nodogsplash desde git
    git clone https://github.com/nodogsplash/nodogsplash.git $nds_dir
    cd $nds_dir
    make
    sudo make install

    delete_if_exists $nds_dir
fi



# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"




# Define the template for nodogsplash.conf
template="GatewayInterface $AP_INTERFACE
GatewayAddress $AP_IP
GatewayPort 2050

FirewallRuleSet authenticated-users {
    FirewallRule allow tcp port 53	
    FirewallRule allow udp port 53	
    FirewallRule allow tcp port 80
    FirewallRule allow tcp port 443
}

FirewallRuleSet preauthenticated-users {
    FirewallRule allow tcp port 53	
    FirewallRule allow udp port 53
}

FirewallRuleSet users-to-router {
    FirewallRule allow udp port 53	
    FirewallRule allow tcp port 53	
    FirewallRule allow udp port 67
}

MaxClients $AP_MAXCLIENTS"


nds_conf="$SCRIPT_DIR/nodogsplash.conf"

# Create the nodogsplash.conf file and substitute the values
write_template_to_file "$template" "$nds_conf"
create_symbolic_link "$nds_conf" "/etc/nodogsplash/nodogsplash.conf" "root"

# Check and add line "nodogsplash"
add_to_rc_local "nodogsplash"

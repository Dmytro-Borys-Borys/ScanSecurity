#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Comprobando si hostapd está instalado
if command -v hostapd &> /dev/null; then
    echo "hostapd is installed"
else
    echo "hostapd is not installed"

    # Instalando hostapd
    sudo apt update
    sudo apt install hostapd -y 
fi

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Rellenando la plantilla del archivo de configuración
template="interface=$AP_INTERFACE
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHANNEL
auth_algs=1
wpa=0"

hostapd_conf="$SCRIPT_DIR/hostapd.conf"
write_template_to_file "$template" "$hostapd_conf"
create_symbolic_link "$hostapd_conf" "/etc/hostapd/hostapd.conf" "root"


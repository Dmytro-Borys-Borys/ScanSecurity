#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Comprobando si hostapd está instalado
if command -v hostapd &>/dev/null; then
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
process_all_templates

create_symbolic_link "$SCRIPT_DIR/hostapd.conf" "/etc/hostapd/hostapd.conf" "root"

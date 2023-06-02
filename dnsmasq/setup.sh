#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

if command -v dnsmasq &>/dev/null; then
    echo "dnsmasq está instalado"
else
    echo "dnsmasq no está instalado"

    # Instalando dnsmasq
    sudo apt install dnsmasq -y
fi

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Procesando todas las plantillas
process_all_templates

# Creando un vínculo a dnsmasq.conf
create_symbolic_link "$SCRIPT_DIR/dnsmasq.conf" "/etc/dnsmasq.conf" "root"

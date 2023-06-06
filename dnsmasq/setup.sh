#!/bin/bash

# Cargando settings generales
set_scriptdir "$BASH_SOURCE"
source "$BASH_SOURCE/../config/config.txt"


# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Instalamos dnsmasq si faltase
verify_dependency "dnsmasq" "sudo apt install dnsmasq -y"

# Procesando todas las plantillas
process_all_templates

# Creando un vínculo a dnsmasq.conf
create_symbolic_link "$SCRIPT_DIR/dnsmasq.conf" "/etc/dnsmasq.conf" "root"

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

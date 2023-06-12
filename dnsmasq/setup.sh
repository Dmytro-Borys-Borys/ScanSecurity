#!/bin/bash

# Cargar settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Cargar settings de red
attempt_to_load "$NETWORK_CONFIG"

# Instalar dnsmasq si hace falta
verify_dependency "dpkg -s dnsmasq" "sudo apt install dnsmasq -y"

# Procesar todas las plantillas
process_all_templates

# Crear un vínculo a dnsmasq.conf
create_symbolic_link "$SCRIPT_DIR/dnsmasq.conf" "/etc/dnsmasq.conf" "root"

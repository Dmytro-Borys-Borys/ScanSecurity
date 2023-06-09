#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Comprobando si hostapd está instalado
verify_dependency "command -v hostapd" "sudo apt install hostapd -y"

# Rellenando la plantilla del archivo de configuración
process_all_templates

create_symbolic_link "$SCRIPT_DIR/hostapd.conf" "/etc/hostapd/hostapd.conf" "root"

run "sudo systemctl unmask hostapd"
run "sudo systemctl enable hostapd"
run "sudo systemctl start hostapd"

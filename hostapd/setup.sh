#!/bin/bash

# Cargando settings generales
set_scriptdir "$BASH_SOURCE"
source "$BASH_SOURCE/../config/config.txt"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Comprobando si hostapd está instalado
verify_dependency "hostapd" "sudo apt install hostapd -y"

# Rellenando la plantilla del archivo de configuración
process_all_templates

create_symbolic_link "$SCRIPT_DIR/hostapd.conf" "/etc/hostapd/hostapd.conf" "root"

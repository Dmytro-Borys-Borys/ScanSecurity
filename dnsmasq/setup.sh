#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Instalamos dnsmasq si faltase
verify_dependency "dpkg -s dnsmasq" "sudo apt install dnsmasq -y"

# Procesando todas las plantillas
process_all_templates

# Creando un vínculo a dnsmasq.conf
create_symbolic_link "$SCRIPT_DIR/dnsmasq.conf" "/etc/dnsmasq.conf" "root"

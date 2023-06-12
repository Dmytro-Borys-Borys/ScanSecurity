#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Procesando todas las plantillas
process_all_templates

# Creando enlace simbólico
create_symbolic_link "$SCRIPT_DIR/interfaces" "/etc/network/interfaces" "root"

# Desbloqueando el adaptador Wi-Fi
run "rfkill unblock wifi" "Habilitando transmisión WiFi"
run "sudo ip addr flush dev $AP_INTERFACE" "Reseteando IPs adaptador $AP_INTERFACE"

#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargar la configuración de Bluetooth
source "$CONFIG_DIR/bluetooth.txt"

# Verificar si hcidump ya está instalado
verify_dependency "command -v hcidump" "sudo apt install bluez-hcidump -y"

change_mode "+x" "$SCRIPT_DIR/monitor.sh"
add_to_rc_local "$SCRIPT_DIR/monitor.sh"
bash "$SCRIPT_DIR/monitor.sh" &


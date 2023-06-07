#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargar la configuración de Bluetooth
source "$CONFIG_DIR/bluetooth.txt"

# Verificar si hcidump ya está instalado
verify_dependency "command -v hcidump" "sudo apt install bluez-hcidump -y"
verify_dependency "command -v inotifywait" "sudo apt install inotify-tools -y"
MONITOR="$SCRIPT_DIR/monitor.sh"
change_mode "+x" "$MONITOR"

process_all_templates

# Create the systemd service unit file
change_mode "+x" "$MONITOR"
install_service "$SCRIPT_DIR/bluetooth-connection.service" "/etc/systemd/system/bluetooth-connection.service"

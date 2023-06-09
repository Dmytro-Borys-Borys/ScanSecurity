#!/bin/bash

# Cargar settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Cargar la configuración de Bluetooth
source "$BLUETOOTH_CONFIG"

# Verificar si hcidump ya está instalado
verify_dependency "command -v hcidump" "sudo apt install bluez-hcidump -y"
verify_dependency "command -v inotifywait" "sudo apt install inotify-tools -y"
MONITOR="$SCRIPT_DIR/monitor.sh"

# Procesar plantillas
process_all_templates

# Instalar servicio
change_mode "+x" "$MONITOR"
install_service "$SCRIPT_DIR/bluetooth-connection.service" "/etc/systemd/system/bluetooth-connection.service"

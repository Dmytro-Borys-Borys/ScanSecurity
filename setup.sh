#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Lista de subcarpetas
subfolders=("libs" "dnsmasq" "freeradius" "hostapd" "iptables" "nodogsplash" "python" "bluetooth" "networking")

# Recorre cada subcarpeta
for folder in "${subfolders[@]}"; do
  change_directory "$SCRIPT_DIR/$folder" || continue # Cambia al directorio o continúa con la siguiente subcarpeta si falla

  # Asigna ejecutable
  change_mode "+x" "setup.sh"

  # Ejecuta el archivo 'setup.sh'
  execute "setup.sh"

  change_directory ".."  # Regresa al directorio anterior
done

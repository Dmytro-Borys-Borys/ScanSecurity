#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Lista de subcarpetas
subfolders=("libs" "dnsmasq" "freeradius" "hostapd" "iptables" "nodogsplash" "python" "bluetooth" "networking")

# Recorre cada subcarpeta
for folder in "${subfolders[@]}"; do
  cd "$folder" || continue # Cambia al directorio o continúa con la siguiente subcarpeta si falla

  # Aplica el comando 'sudo chmod -x setup.sh'
  run "sudo chmod -x setup.sh" "cambiando permisos de $folder/setup.sh"

  # Ejecuta el archivo 'setup.sh'
  sudo bash setup.sh

  cd ..  # Regresa al directorio anterior
done

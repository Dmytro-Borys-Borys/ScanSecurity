#!/bin/bash

# Lista de subcarpetas
subfolders=("dnsmasq" "freeradius" "hostapd" "iptables" "nodogsplash" "python" "networking")

# Recorre cada subcarpeta
for folder in "${subfolders[@]}"; do
  cd "$folder" || continue  # Cambia al directorio o continúa con la siguiente subcarpeta si falla

  # Aplica el comando 'sudo chmod -x setup.sh'
  sudo chmod -x setup.sh

  # Ejecuta el archivo 'setup.sh'
  sudo bash setup.sh

  cd ..  # Regresa al directorio anterior
done

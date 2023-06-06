#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Define la nueva configuración utilizando las variables
new_config="auto $AP_INTERFACE
iface $AP_INTERFACE inet static
    address $AP_IP
    netmask $AP_NETMASK"

# Elimina las líneas existentes de $AP_INTERFACE en /etc/network/interfaces
sudo sed -n -i -e "/^auto $AP_INTERFACE/,/^$/d" /etc/network/interfaces

# Agrega la nueva configuración a /etc/network/interfaces
echo "$new_config" | sudo tee -a /etc/network/interfaces >/dev/null

rfkill unblock wifi
sudo ip addr flush dev $AP_INTERFACE

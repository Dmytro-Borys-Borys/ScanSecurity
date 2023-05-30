#!/bin/sh

# Cargando settings generales
source "../config/config.txt"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Limpiar todas las reglas y cadenas existentes en iptables
sudo iptables -F  # Flush todas las reglas en todas las cadenas
sudo iptables -X  # Eliminar todas las cadenas definidas por el usuario
sudo iptables -t nat -F  # Flush todas las reglas en la tabla NAT
sudo iptables -t nat -X  # Eliminar todas las cadenas definidas por el usuario en la tabla NAT
sudo iptables -t mangle -F  # Flush todas las reglas en la tabla Mangle
sudo iptables -t mangle -X  # Eliminar todas las cadenas definidas por el usuario en la tabla Mangle

# Configurar las reglas de reenvío de paquetes
sudo iptables -A FORWARD -i $GW_INTERFACE -o $AP_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $AP_INTERFACE -o $GW_INTERFACE -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o $GW_INTERFACE -j MASQUERADE

# Guardar las reglas de iptables en un archivo
sudo sh -c "iptables-save > $IPTABLES_FILE"

# Check and add line "iptables-restore < /etc/iptables.ipv4.nat"
add_to_rc_local "iptables-restore < $IPTABLES_FILE"

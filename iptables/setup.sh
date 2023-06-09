#!/bin/sh

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Limpiar todas las reglas y cadenas existentes en iptables
run "sudo iptables -v -F; \
    sudo iptables -v -X; \
    sudo iptables -v -t nat -F; \
    sudo iptables -v -t nat -X; \
    sudo iptables -v -t mangle -F; \
    sudo iptables -v -t mangle -X; \
    sudo iptables -v -A FORWARD -i $GW_INTERFACE -o $AP_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A FORWARD -i $AP_INTERFACE -o $GW_INTERFACE -j ACCEPT; \
    sudo iptables -v -t nat -A POSTROUTING -o $GW_INTERFACE -j MASQUERADE" "Ajustando iptables"

# Guardar las reglas de iptables en un archivo
run "sudo sh -c \"iptables-save > $IPTABLES_FILE\"" "Guardando las reglas iptables en $IPTABLES_FILE"

ip_forward_value=$(sysctl -n net.ipv4.ip_forward)
if [[ "$ip_forward_value" -eq 0 ]]; then
    # echo "Enabling IP forwarding..."

    # Modify sysctl.conf file to enable IP forwarding
    run "--quiet" "echo \"net.ipv4.ip_forward = 1\" | sudo tee -a /etc/sysctl.conf" "Editando fichero: /etc/sysctlconf"

    # Reload sysctl settings
    run "sudo sysctl -p" "Recargando: sysctl"

    # Modify the current environment to enable IP forwarding
    run "--quiet" "echo \"1\" | sudo tee /proc/sys/net/ipv4/ip_forward" "Asignando ip_forward=1 al entorno actual"
fi


# Check and add line "iptables-restore < /etc/iptables.ipv4.nat"
add_to_rc_local "iptables-restore < $IPTABLES_FILE"

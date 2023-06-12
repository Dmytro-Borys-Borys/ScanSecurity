#!/bin/sh

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

# Limpiar todas las reglas y cadenas existentes en iptables
run "sudo iptables -v -F; \
    sudo iptables -v -X; \
    sudo iptables -v -t nat -F; \
    sudo iptables -v -t nat -X; \
    sudo iptables -v -t mangle -F; \
    sudo iptables -v -t mangle -X; \
    sudo iptables -v -P INPUT DROP; \
    sudo iptables -v -P FORWARD DROP; \
    sudo iptables -v -P OUTPUT DROP; \
    sudo iptables -v -A FORWARD -i $GW_INTERFACE -o $AP_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A FORWARD -i $AP_INTERFACE -o $GW_INTERFACE -j ACCEPT; \
    sudo iptables -v -t nat -A POSTROUTING -o $GW_INTERFACE -j MASQUERADE; \
    sudo iptables -v -A INPUT -i $GW_INTERFACE -p icmp -j ACCEPT; \
    sudo iptables -v -A OUTPUT -o $GW_INTERFACE -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A INPUT -i $GW_INTERFACE -p tcp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A INPUT -i $GW_INTERFACE -p udp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A OUTPUT -o $GW_INTERFACE -p tcp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A OUTPUT -o $GW_INTERFACE -p udp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT; \
    sudo iptables -v -A INPUT -i lo -p udp -j ACCEPT; \
    sudo iptables -v -A INPUT -i lo -p tcp -j ACCEPT; \
    sudo iptables -v -A OUTPUT -o lo -p udp -j ACCEPT; \
    sudo iptables -v -A OUTPUT -o lo -p tcp -j ACCEPT" "Ajustando iptables"


# Guardar las reglas de iptables en un archivo
run "sudo sh -c \"iptables-save > $IPTABLES_FILE\"" "Guardando las reglas iptables en $IPTABLES_FILE"

ip_forward_value=$(sysctl -n net.ipv4.ip_forward)
if [[ "$ip_forward_value" -eq 0 ]]; then
    # Habilitando IP forwarding

    # Modificando sysctl.conf para habilitar IP forwarding
    run "--quiet" "echo \"net.ipv4.ip_forward = 1\" | sudo tee -a /etc/sysctl.conf" "Editando fichero: /etc/sysctlconf"

    # Modificando el entorno actual para habilitar IP forwarding sin reiniciar
    run "--quiet" "echo \"1\" | sudo tee /proc/sys/net/ipv4/ip_forward" "Asignando ip_forward=1 al entorno actual"

    # Recargando sysctl
    run "sudo sysctl -p" "Recargando: sysctl"
fi


# Nos aseguramos de restaurar las reglas de iptables del archivo $IPTABLES_FILE
add_to_rc_local "iptables-restore < $IPTABLES_FILE"

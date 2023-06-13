#!/bin/bash

##########################################################
# Script de Conexión Bluetooth y Ejecución de Subscripts #
##########################################################

# Descripción del archivo:
#   Este script intenta establecer una conexión Bluetooth con un dispositivo específico.
#   Una vez establecida la conexión, verifica si se transmite una secuencia de datos específica
#   a través del canal Bluetooth. Si se encuentra la secuencia, ejecuta el script "newcred.sh"
#   con el argumento "1". El script "newcred.sh" es responsable de realizar alguna acción
#   basada en la secuencia detectada. Luego, el script espera $BLUETOOTH_TIMEOUT segundos y
#   repite el proceso.

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Cargar la configuración de Bluetooth
source "$BLUETOOTH_CONFIG"

# Realizar la configuración necesaria
bluetoothctl power on        # Asegurarse de que Bluetooth esté encendido
bluetoothctl agent on        # Habilitar el agente para emparejamiento

# Verificar si el dispositivo está emparejado o si se agotó el tiempo de espera
while ! bluetoothctl info "$BLUETOOTH_DEVICE" | grep -q "Paired: yes"; do
    echo "El dispositivo no está emparejado. Intentando emparejar..."
    # Confiando en el dispositivo
    bluetoothctl trust "$BLUETOOTH_DEVICE"

    if [[ -z "$scan_pid" ]]; then

        # bluetoothctl discoverable on # Configurar el dispositivo para modo de anuncio y buscar dispositivos

        # Ejecutar el comando "bluetoothctl scan on" en segundo plano y capturar su PID
        bluetoothctl scan on &
        scan_pid=$!
    fi

    # Intentar emparejar con el dispositivo
    echo "Intentando emparejar con $BLUETOOTH_DEVICE"
    bluetoothctl pair "$BLUETOOTH_DEVICE"

    # Verificar el estado de salida del comando anterior
    if [ $? -eq 0 ]; then
        # Emparejamiento exitoso, salir del bucle
        echo "Emparejamiento exitoso."
        break
    fi

    # Esperar un corto período antes del próximo intento
    sleep "$BLUETOOTH_TIMEOUT"
done
while ! bluetoothctl info "$BLUETOOTH_DEVICE" | grep -q "Connected: yes"; do
    bluetoothctl connect "$BLUETOOTH_DEVICE"
done
while true; do

    if [[ -n "$scan_pid" ]]; then
        # Finalizar el proceso de búsqueda
        kill "$scan_pid"
        unset scan_pid

        # Confiar y conectar al dispositivo
        # 
        # bluetoothctl connect "$BLUETOOTH_DEVICE"

        # Desactivar el modo de anuncio
        bluetoothctl discoverable off

        # Deshabilitar el agente
        bluetoothctl agent off
    fi

    # Verificar si se encuentra la secuencia de datos específica
    echo "Escuchando la entrada $BLUETOOTH_DATA_SEQUENCE ..."
    timeout "$BLUETOOTH_TIMEOUT" hcidump --raw | grep --line-buffered "$BLUETOOTH_DATA_SEQUENCE" | while read -r event; do echo "$BLUETOOTH_EVENT"; done | tee "$BLUETOOTH_EVENTLOG"

    # Esperar $BLUETOOTH_TIMEOUT segundos entre intentos
    echo "Esperando $BLUETOOTH_TIMEOUT segundos..."
    #sleep
done

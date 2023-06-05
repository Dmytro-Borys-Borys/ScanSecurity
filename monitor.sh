#!/bin/bash

##########################################################
# Script de Conexión Bluetooth y Ejecución de Subscriptos #
##########################################################

# Descripción del archivo:
#   Este script intenta establecer una conexión Bluetooth con un dispositivo
#   específico. Una vez establecida la conexión, verifica si hay una secuencia
#   específica de datos transmitida a través del canal Bluetooth. Si se encuentra
#   la secuencia, ejecuta el script "newcred.sh" pasando el argumento "1". El
#   script "newcred.sh" es responsable de realizar alguna acción basada en la
#   secuencia detectada. Luego, el script espera 10 segundos y repite el proceso.

# Cargando la configuración de Bluetooth
source "config/bluetooth.txt"

echo $BLUETOOTH_DEVICE $BLUETOOTH_DATA_SEQUENCE $BLUETOOTH_TIMEOUT

while true; do
    # Intentar establecer conexión con el dispositivo
    while ! bluetoothctl connect "$BLUETOOTH_DEVICE"; do
        echo "Conexión fallida, intentando de nuevo..."
    done

    # Verificar si se encuentra la secuencia de datos específica
    if sudo hcidump --raw | grep -q "$BLUETOOTH_DATA_SEQUENCE"; then
        ./newcred.sh 1
    fi

    # Espera $BLUETOOTH_TIMEOUT segundos entre intentos
    sleep $BLUETOOTH_TIMEOUT
done

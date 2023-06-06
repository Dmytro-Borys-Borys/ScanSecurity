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

#!/bin/bash

# Check if hcidump is already installed
if command -v hcidump &>/dev/null; then
    echo "hcidump is already installed."
else
    # Check if apt package manager is available
    if command -v apt-get &>/dev/null; then
        echo "Installing hcidump using apt-get..."
        sudo apt-get update
        sudo apt-get install bluez-hcidump -y
        echo "hcidump is now installed."
    else
        echo "apt-get package manager is not available. Please install bluez package manually to use hcidump."
        exit 1
    fi
fi


echo $BLUETOOTH_DEVICE $BLUETOOTH_DATA_SEQUENCE $BLUETOOTH_TIMEOUT

while true; do

    if bluetoothctl info "$BLUETOOTH_DEVICE" | grep -q "Paired: yes"; then
        echo "Device is already paired."
    else
        echo "Device is not paired. Pairing..."

        bluetoothctl power on  # Ensure Bluetooth is powered on
        bluetoothctl agent on  # Enable agent for pairing

        # Set the device to broadcast mode and scan for devices
        bluetoothctl discoverable on

        # Run the "bluetoothctl scan on" command in the background and capture its PID
        # bluetoothctl scan on & scan_pid=$!

        # Loop until the device is paired or timeout occurs
        while true; do
            # Attempt to pair with the device
            bluetoothctl connect  "$BLUETOOTH_DEVICE"

            # Check the exit status of the previous command
            if [ $? -eq 0 ]; then
                # Pairing successful, break out of the loop
                break
            fi

            # Sleep for a short period before the next attempt
            sleep 1
        done

        # Kill the scan process
        # kill "$scan_pid"

        # Trust and connect to the device
        bluetoothctl trust "$BLUETOOTH_DEVICE"
        bluetoothctl connect "$BLUETOOTH_DEVICE"

        # Turn off discoverable mode
        bluetoothctl discoverable off

        # Disable the agent
        bluetoothctl agent off

        echo "Pairing completed."
    fi
    # # Intentar establecer conexión con el dispositivo
    # while ! bluetoothctl connect "$BLUETOOTH_DEVICE"; do
    #     echo "Conexión fallida, intentando de nuevo..."
    # done

    # Verificar si se encuentra la secuencia de datos específica
    if sudo hcidump --raw | grep -q "$BLUETOOTH_DATA_SEQUENCE"; then
        ./newcred.sh 1
    fi

    # Espera $BLUETOOTH_TIMEOUT segundos entre intentos
    sleep $BLUETOOTH_TIMEOUT
done

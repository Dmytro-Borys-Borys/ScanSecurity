#!/bin/bash

#########################################################
# Script de Creación de Usuario y Generación de Código QR #
#########################################################

# Uso del script:
#   Este script genera un usuario aleatorio y una contraseña,
#   luego calcula el hash NTLM de la contraseña y lo inserta en
#   una base de datos SQLite. También genera un código QR con
#   la información del usuario y la contraseña. Opcionalmente,
#   se puede proporcionar un parámetro numérico que representa
#   el número de horas para establecer una fecha de expiración
#   del usuario en la base de datos.

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

touch "$BLUETOOTH_EVENTLOG"

while inotifywait -e modify "$BLUETOOTH_EVENTLOG"; do
    if grep -q "$BLUETOOTH_EVENT" "$BLUETOOTH_EVENTLOG"; then
        sudo rm "$BLUETOOTH_EVENTLOG"

        # Cargando settings de red
        attempt_to_load "$NETWORK_CONFIG"
        attempt_to_load "$BUSINESS_CONFIG"

        DEFAULT_LOGIN_LEN=8     # Longitud de login por defecto
        DEFAULT_PASSWORD_LEN=10 # Longitud de la contraseña por defecto

        # Generar un usuario aleatorio de $DEFAULT_LOGIN_LEN caracteres
        login=$(pwgen -0A "$DEFAULT_LOGIN_LEN" 1)

        # Generar una contraseña aleatoria de $DEFAULT_PASSWORD_LEN caracteres
        password=$(pwgen "$DEFAULT_PASSWORD_LEN" 1)

        echo "creds: $login $password"

        # Función para ejecutar queries en la base de datos de FreeRADIUS
        sqlite_sql() {
            echo $(sudo sqlite3 "$RADIUS_DB" "$1")
        }

        # Comprobar si el nombre de usuario ya está en uso.
        matches=$(sqlite_sql "SELECT COUNT(*) FROM radcheck WHERE username='$username';")
        
        if [ $matches -gt 0 ]; then
            echo "El nombre de usuario $login ya está en uso."
            exit 1
        else
            echo "El nombre de usuario $login está disponible."
        fi

        # Calcular el hash NTLM de la contraseña proporcionada.
        hash=$(smbencrypt "$password" 2> /dev/null | cut -f 2)

        # Lógica adicional para el tiempo de expiración
        if [[ $1 =~ ^[0-9]+$ ]]; then
            expiration=$(date -d "+$1 hour" +"%d %b %Y %H:%M:%S")
        else
            expiration=""
        fi

        # Insertar el usuario en la base de datos.
        sqlite_sql "INSERT INTO radcheck (username,attribute,op,value) VALUES ('$login','NT-Password',':=','$hash');"
        if [[ -n "$expiration" ]]; then
            sqlite_sql "INSERT INTO radcheck (username,attribute,op,value) VALUES ('$login','Expiration',':=','$expiration');"
        fi

        # Generar el código QR
        python3 ${SCRIPT_DIR}/../python/qrcode.py "$login" "$password" "$AP_IP" "$AP_SSID" "$expiration" "$BUSINESS_NAME" "$BUSINESS_ADDRESS" "../images/$TICKET_LOGO_TEXT" "../images/$TICKET_LOGO_IMAGE"
    fi
done

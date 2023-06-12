#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"


run "sudo git clone https://github.com/Dmytro-Borys-Borys/Spinner.git \"$SCRIPT_DIR/Spinner\"" "Clonando repositorio Spinner"

# Aplica el comando 'sudo chmod -x setup.sh'
change_mode "+x" "$SPINNER"
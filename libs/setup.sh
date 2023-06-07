#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

git clone https://github.com/Dmytro-Borys-Borys/Spinner.git "$SCRIPT_DIR/Spinner"
bash $SPINNER "chmod +x $SPINNER"
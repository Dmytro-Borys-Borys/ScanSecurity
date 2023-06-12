#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

# Instalación de dependencias
verify_dependency "command -v pip" "sudo apt install python3-pip -y"
verify_pip_dependency "pyqrcode"
verify_pip_dependency "escpos"


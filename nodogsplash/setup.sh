#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.env"
SCRIPT_DIR="$(set_scriptdir "$BASH_SOURCE")"

attempt_to_load "$AUTH_CONFIG" # Cargando settings de autenticación
attempt_to_load "$BUSINESS_CONFIG" # Cargando settings del establecimiento
attempt_to_load "$NETWORK_CONFIG" # Cargando settings de red

# Instalando nodogsplash
verify_dependency "command -v nodogsplash" "sudo bash $SCRIPT_DIR/getnodogsplash.sh"

auth_script="$SCRIPT_DIR/auth.sh"
auth_link="/etc/nodogsplash/auth.sh"

# Procesando las plantillas
process_all_templates

# Creando enlaces
create_symbolic_link $auth_script $auth_link "root"
change_mode "+x" "$auth_script"
# change_mode "+x" "$auth_link"
create_symbolic_link "$SCRIPT_DIR/nodogsplash.conf" "/etc/nodogsplash/nodogsplash.conf" "root"
create_symbolic_link "$SCRIPT_DIR/$NDS_PAGE" "/etc/nodogsplash/htdocs/$NDS_PAGE" "root"
create_symbolic_link "$SCRIPT_DIR/bootstrap.min.css" "/etc/nodogsplash/htdocs/bootstrap.min.css" "root"
create_symbolic_link "$BASE_DIR/images/$NDS_LOGO" "/etc/nodogsplash/htdocs/images/$NDS_LOGO" "root"

# Estableciendo inicio automático
add_to_rc_local "nodogsplash"

#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargando settings de red
attempt_to_load "$AUTH_CONFIG"
attempt_to_load "$BUSINESS_CONFIG"

verify_dependency "nodogsplash" "sudo bash $SCRIPT_DIR/getnodogsplash.sh"

# Cargando settings de red
attempt_to_load "$NETWORK_CONFIG"

auth_script="$SCRIPT_DIR/auth.sh"
auth_link="/etc/nodogsplash/auth.sh"

process_all_templates

chmod +x "$auth_script"
create_symbolic_link $auth_script $auth_link "root"
create_symbolic_link "$SCRIPT_DIR/nodogsplash.conf" "/etc/nodogsplash/nodogsplash.conf" "root"
create_symbolic_link "$SCRIPT_DIR/$NDS_PAGE" "/etc/nodogsplash/htdocs/$NDS_PAGE" "root"
create_symbolic_link "$SCRIPT_DIR/bootstrap.min.css" "/etc/nodogsplash/htdocs/bootstrap.min.css" "root"
create_symbolic_link "$BASE_DIR/images/$NDS_LOGO" "/etc/nodogsplash/htdocs/images/$NDS_LOGO" "root"

# Check and add line "nodogsplash"
add_to_rc_local "nodogsplash"

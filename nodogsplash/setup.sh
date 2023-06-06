#!/bin/bash

# Cargando settings generales
set_scriptdir "$BASH_SOURCE"
source "$BASH_SOURCE/../config/config.txt"

# Cargando settings de red
attempt_to_load "$AUTH_CONFIG"
attempt_to_load "$BUSINESS_CONFIG"

# Comprobar si nodogsplash se encuentra instalado
if command -v nodogsplash &>/dev/null; then
  echo "nodogsplash is installed"
else
  echo "nodogsplash is not installed"
  # Instalando requisitos previos nodogsplash
  sudo apt update
  sudo apt install build-essential debhelper devscripts git libmicrohttpd-dev -y

  nds_dir="$BASE_DIR/ignores/nodogsplash"

  delete_if_exists $nds_dir

  # Instalando nodogsplash desde git
  git clone https://github.com/nodogsplash/nodogsplash.git $nds_dir
  cd $nds_dir
  make
  sudo make install

  delete_if_exists $nds_dir
fi

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

#!/bin/bash

# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

sudo apt update
sudo apt install build-essential debhelper devscripts git libmicrohttpd-dev -y

nds_dir="$BASE_DIR/ignores/nodogsplash"

delete_if_exists $nds_dir

# Instalando nodogsplash desde git
sudo git clone https://github.com/nodogsplash/nodogsplash.git $nds_dir
cd $nds_dir
make
sudo make install

delete_if_exists $nds_dir
#!/bin/bash

# Cargando settings generales
set_scriptdir "$BASH_SOURCE"
source "$BASH_SOURCE/../config/config.txt"

# Cargando settings de red
attempt_to_load "$AUTH_CONFIG"

# Habilitando una carpeta para la base de datos
if [[ ! -d "$RADIUS_DB_FOLDER" ]]; then
    sudo mkdir -pv "$RADIUS_DB_FOLDER"
fi

# Estableciendo los permisos de la carpeta de la base de datos
sudo chown -R freerad:freerad "$RADIUS_DB_FOLDER"

# Instalando FreeRADIUS y sqlite3 si hace falta
verify_dependency "freeradius" "sudo apt install freeradius -y"
verify_dependency "sqlite3" "sudo apt install sqlite3 -y"

# schema_file="/etc/freeradius/3.0/mods-config/sql/main/sqlite/schema.sql"
# # Comprueba si el archivo de la base de datos ya existe
# if ! sudo -u freerad test ! -f "$RADIUS_DB"; then
# 	# Comprueba si el archivo de esquema existe
# 	if [[ ! -f "$schema_file" ]]; then
# 		echo "Archivo de esquema no encontrado: $schema_file"
# 	else
# 		# Crea la base de datos SQLite y ejecuta el archivo schema.sql
# 		sudo -u freerad sqlite3 "$RADIUS_DB" <"$schema_file"

# 		# Comprueba si el archivo schema.sql se ejecutó correctamente
# 		if [[ $? -eq 0 ]]; then
# 			echo "La inicialización de la base de datos se realizó correctamente."
# 		else
# 			echo "Error al inicializar la base de datos."
# 			exit 1
# 		fi
# 	fi
# fi

process_all_templates
delete_if_exists "/etc/freeradius/3.0/clients.conf"
create_symbolic_link "$SCRIPT_DIR/clients.conf" "/etc/freeradius/3.0/clients.conf" "freerad"
delete_if_exists "/etc/freeradius/3.0/mods-enabled/sql"
create_symbolic_link "$SCRIPT_DIR/sql" "/etc/freeradius/3.0/mods-enabled/sql" "freerad"
delete_if_exists "/etc/freeradius/3.0/sites-enabled/default"
create_symbolic_link "$SCRIPT_DIR/default" "/etc/freeradius/3.0/sites-enabled/default" "freerad"

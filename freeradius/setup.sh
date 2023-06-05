#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargando settings de red
attempt_to_load "$AUTH_CONFIG"

schema_file="/etc/freeradius/3.0/mods-config/sql/main/sqlite/schema.sql"

if [[ ! -d "$RADIUS_DB_FOLDER" ]]; then
    sudo mkdir -pv "$RADIUS_DB_FOLDER"
	sudo chown -R freerad:freerad "$RADIUS_DB_FOLDER"
fi

# Comprueba si el archivo de la base de datos ya existe
if [[ ! -f "$RADIUS_DB" ]]; then
	# Comprueba si el archivo de esquema existe
	if [[ ! -f "$schema_file" ]]; then
		echo "Archivo de esquema no encontrado: $schema_file"
	else
		# Crea la base de datos SQLite y ejecuta el archivo schema.sql
		sudo -u freerad sqlite3 "$RADIUS_DB" <"$schema_file"

		# Comprueba si el archivo schema.sql se ejecutó correctamente
		if [[ $? -eq 0 ]]; then
			echo "La inicialización de la base de datos se realizó correctamente."
		else
			echo "Error al inicializar la base de datos."
			exit 1
		fi
	fi
fi

process_all_templates
create_symbolic_link "$SCRIPT_DIR/clients.conf" "/etc/freeradius/3.0/clients.conf" "freerad"
create_symbolic_link "$SCRIPT_DIR/sql" "/etc/freeradius/3.0/mods-enabled/sql" "freerad"
create_symbolic_link "$SCRIPT_DIR/default" "/etc/freeradius/3.0/sites-enabled/default" "freerad"

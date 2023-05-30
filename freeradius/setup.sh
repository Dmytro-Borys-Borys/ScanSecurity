#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Cargando settings de red
attempt_to_load "$AUTH_CONFIG"


# Define the template for nodogsplash.conf
template="client localhost {
	ipaddr = 127.0.0.1
	proto = *
	secret = $SHARED_SECRET
	require_message_authenticator = no
	nas_type	 = other	
	limit {
		max_connections = 16
		lifetime = 0
		idle_timeout = 30
	}
}"
clients_conf="$SCRIPT_DIR/clients.conf"
write_template_to_file "$template" "$clients_conf"
create_symbolic_link "$clients_conf" "/etc/freeradius/3.0/clients.conf" "freerad"

sqlite_db="$SCRIPT_DIR/freeradius.db"

template="sql {
	dialect = \"sqlite\"
	driver = \"rlm_sql_\${dialect}\"
	sqlite {
		filename = \"$sqlite_db\"
		busy_timeout = 200
		bootstrap = \"\${modconfdir}/\${..:name}/main/sqlite/schema.sql\"
	}

	radius_db = \"radius\"
	acct_table1 = \"radacct\"
	acct_table2 = \"radacct\"
	postauth_table = \"radpostauth\"
	authcheck_table = \"radcheck\"
	groupcheck_table = \"radgroupcheck\"
	authreply_table = \"radreply\"
	groupreply_table = \"radgroupreply\"
	usergroup_table = \"radusergroup\"
	delete_stale_sessions = yes
}"

sql_conf="$SCRIPT_DIR/sql"
write_template_to_file "$template" "$sql_conf"
delete_if_exists "/etc/freeradius/3.0/mods-enabled/sql"
create_symbolic_link "$sql_conf" "/etc/freeradius/3.0/mods-enabled/sql-scansecurity" "freerad"

default_site="$SCRIPT_DIR/default"
delete_if_exists "/etc/freeradius/3.0/sites-enabled/default"
create_symbolic_link "$default_site" "/etc/freeradius/3.0/sites-enabled/default-scansecurity" "freerad"

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

schema_file="/etc/freeradius/3.0/mods-config/sql/main/sqlite/schema.sql"

# Check if the database file already exists
if [[ -f "$RADIUS_DB" ]]; then
    echo "Database file already exists."
else
		# Check if the schema file exists
	if [[ ! -f "$schema_file" ]]; then
		echo "Schema file not found: $schema_file"
	else
		# Create the SQLite database and execute the schema.sql file
		 sudo -u freerad sqlite3 "$RADIUS_DB" <<EOF
.read "$schema_file"
EOF

		# Check if the schema.sql file was executed successfully
		if [[ $? -eq 0 ]]; then
			#sudo chown freerad:freerad $RADIUS_DB
			echo "Database bootstrap successful."
		else
			echo "Error bootstrapping the database."
			exit 1
		fi	
	fi
fi






template="sql {
	dialect = \"sqlite\"
	driver = \"rlm_sql_\${dialect}\"
	sqlite {
		filename = \"${RADIUS_DB}\"
		busy_timeout = 200
		bootstrap = \"\${modconfdir}/\${..:name}/main/sqlite/schema.sql\"
	}


	mysql {
		tls {
			ca_file = \"/etc/ssl/certs/my_ca.crt\"
			ca_path = \"/etc/ssl/certs/\"
			certificate_file = \"/etc/ssl/certs/private/client.crt\"
			private_key_file = \"/etc/ssl/certs/private/client.key\"
			cipher = \"DHE-RSA-AES256-SHA:AES128-SHA\"
			tls_required = yes
			tls_check_cert = no
			tls_check_cert_cn = no
		}
		warnings = auto
	}
	postgresql {
		send_application_name = yes
	}
	mongo {
		appname = \"freeradius\"
		tls {
			certificate_file = /path/to/file
			certificate_password = \"password\"
			ca_file = /path/to/file
			ca_dir = /path/to/directory
			crl_file = /path/to/file
			weak_cert_validation = false
			allow_invalid_hostname = false
		}
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
	pool {
		start = \${thread[pool].start_servers}
		min = \${thread[pool].min_spare_servers}
		max = \${thread[pool].max_servers}
		spare = \${thread[pool].max_spare_servers}
		uses = 0
		retry_delay = 30
		lifetime = 0
		idle_timeout = 60
	}
	client_table = \"nas\"
	group_attribute = \"SQL-Group\"
	\$INCLUDE \${modconfdir}/\${.:name}/main/\${dialect}/queries.conf
}"

sql_conf="$SCRIPT_DIR/sql"
write_template_to_file "$template" "$sql_conf"
delete_if_exists "/etc/freeradius/3.0/mods-enabled/sql"
create_symbolic_link "$sql_conf" "/etc/freeradius/3.0/mods-enabled/sql" "freerad"

default_site="$SCRIPT_DIR/default"
delete_if_exists "/etc/freeradius/3.0/sites-enabled/default"
create_symbolic_link "$default_site" "/etc/freeradius/3.0/sites-enabled/default" "freerad"

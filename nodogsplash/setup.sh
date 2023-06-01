#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"
# Cargando settings de red
attempt_to_load "$AUTH_CONFIG"


# Comprobar si nodogsplash se encuentra instalado
if command -v nodogsplash &> /dev/null; then
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

template="#!/bin/bash

SHARED_SECRET='$SHARED_SECRET'


echo \$@ >> /var/log/ndsauth.log

echo \$SHARED_SECRET >> /var/log/ndsauth.log


METHOD=\"\$1\"
MAC=\"\$2\"

case \"\$METHOD\" in
  auth_client)
    USERNAME=\"\$3\"
    PASSWORD=\"\$4\"
    radtest -x \$USERNAME \$PASSWORD localhost 1812 \$SHARED_SECRET >> /var/log/ndsauth.log
    result=\$?
    if [[ \$result -eq 0 ]]; then
    
      # Allow client to access the Internet for one hour (3600 seconds)
      # Further values are upload and download limits in bytes. 0 for no limit.
      echo 3600 0 0
      exit 0
    else
      # Deny client to access the Internet.
      echo \$result
      exit 1
    fi
    ;;
  client_auth|client_deauth|idle_deauth|timeout_deauth|ndsctl_auth|ndsctl_deauth|shutdown_deauth)
    INGOING_BYTES=\"\$3\"
    OUTGOING_BYTES=\"\$4\"
    SESSION_START=\"\$5\"
    SESSION_END=\"\$6\"
    # client_auth: Client authenticated via this script.
    # client_deauth: Client deauthenticated by the client via splash page.
    # idle_deauth: Client was deauthenticated because of inactivity.
    # timeout_deauth: Client was deauthenticated because the session timed out.
    # ndsctl_auth: Client was authenticated by the ndsctl tool.
    # ndsctl_deauth: Client was deauthenticated by the ndsctl tool.
    # shutdown_deauth: Client was deauthenticated by Nodogsplash terminating.
    ;;
esac"

write_template_to_file "$template" "$auth_script"
chmod +x "$auth_script"
create_symbolic_link $auth_script $auth_link "root"

# Define the template for nodogsplash.conf
template="GatewayInterface $AP_INTERFACE
GatewayAddress $AP_IP
GatewayName $AP_SSID
GatewayPort 2050

BinAuth $auth_link

FirewallRuleSet authenticated-users {
    FirewallRule allow tcp port 53	
    FirewallRule allow udp port 53	
    FirewallRule allow tcp port 80
    FirewallRule allow tcp port 443
}

FirewallRuleSet preauthenticated-users {
    FirewallRule allow tcp port 53	
    FirewallRule allow udp port 53
}

FirewallRuleSet users-to-router {
    FirewallRule allow udp port 53	
    FirewallRule allow tcp port 53	
    FirewallRule allow udp port 67
}

MaxClients $AP_MAXCLIENTS


DebugLevel 3"


nds_conf="$SCRIPT_DIR/nodogsplash.conf"

# Create the nodogsplash.conf file and substitute the values
write_template_to_file "$template" "$nds_conf"
create_symbolic_link "$nds_conf" "/etc/nodogsplash/nodogsplash.conf" "root"


nds_splash_path="/etc/nodogsplash/htdocs/$NDS_PAGE"
local_splash_path="$SCRIPT_DIR/$NDS_PAGE"
create_symbolic_link "$local_splash_path" "$nds_splash_path" "root"

nds_css_path="/etc/nodogsplash/htdocs/bootstrap.min.css"
local_css_path="$SCRIPT_DIR/bootstrap.min.css"
create_symbolic_link "$local_css_path" "$nds_css_path" "root"

create_symbolic_link "$SCRIPT_DIR/images/$NDS_LOGO" "/etc/nodogsplash/htdocs/images/$NDS_LOGO" "root"

# Check and add line "nodogsplash"
add_to_rc_local "nodogsplash"

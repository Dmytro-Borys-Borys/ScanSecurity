#!/bin/sh

# Carpeta donde se encuentra nuestro script
script_dir="$(dirname "$(realpath "$0")")"

# El repositorio tiene que estar ubicado en un nivel superior
repo_dir=$(dirname "$script_dir")

sudo apt update

# Instalando git
sudo apt install git

# Instalando hostapd
sudo apt install hostapd -y 

# Instalando dnsmasq
sudo apt install dnsmasq -y

# Instalando requisitos previos nodogsplash
sudo apt install build-essential debhelper devscripts git libmicrohttpd-dev -y

nds_dir="${repo_dir}/ignores/nodogsplash"
# Instalando nodogsplash desde git
git clone https://github.com/nodogsplash/nodogsplash.git $nds_dir
cd $nds_dir
make
sudo make install
rm -rf $nds_dir


file="/etc/rc.local"


add_line_if_not_exists() {
    line=$1
    
    # Check if the line exists in the file
    if grep -qF "$line" "$file"; then
        # echo "Line already exists in $file"
    else
        # Add the line above "exit 0" in the file
        sudo sed -i "/^exit 0/i $line" "$file"
        # echo "Line added to $file"
    fi
}

# Check and add line "nodogsplash"
add_line_if_not_exists "nodogsplash"

# Check and add line "iptables-restore < /etc/iptables.ipv4.nat"
add_line_if_not_exists "iptables-restore < /etc/iptables.ipv4.nat"
#!/bin/sh

# Carpeta donde se encuentra nuestro script
script_dir="$(dirname "$(realpath "$0")")"



echo "$(dirname "script_dir")"

echo $script_dir

# El repositorio tiene que estar ubicado en un nivel superior
repo_dir=$(dirname "$script_dir")
echo $repo_dir


declare -A files=(
    [$repo_dir/freeradius/clients.conf]="/etc/freeradius/3.0/clients.conf"
    # Add more file-link pairs as needed
)

# Iterate over the array and create the symbolic links
for source_path in "${!files[@]}"; do
    target_path="${files[$source_path]}"
    sudo rm -v "$target_path"
    sudo ln -sv "$source_path" "$target_path"
    sudo chown -Rv freerad:freerad "$target_path"
done


declare -A files=(

    [$repo_dir/hostapd/hostapd.conf]="/etc/hostapd/hostapd.conf"
    # Add more file-link pairs as needed
)

# Iterate over the array and create the symbolic links
for source_path in "${!files[@]}"; do
    target_path="${files[$source_path]}"
    sudo rm -v "$target_path"
    sudo ln -sv "$source_path" "$target_path"
done

declare -A files=(

    [$repo_dir/dnsmasq/dnsmasq.conf]="/etc/dnsmasq.conf"
    # Add more file-link pairs as needed
)

# Iterate over the array and create the symbolic links
for source_path in "${!files[@]}"; do
    target_path="${files[$source_path]}"
    sudo rm -v "$target_path"
    sudo ln -sv "$source_path" "$target_path"
done

declare -A files=(

    [$repo_dir/nodogsplash/nodogsplash.conf]="/etc/nodogsplash/nodogsplash.conf"
    # Add more file-link pairs as needed
)

# Iterate over the array and create the symbolic links
for source_path in "${!files[@]}"; do
    target_path="${files[$source_path]}"
    sudo rm -v "$target_path"
    sudo ln -sv "$source_path" "$target_path"
done

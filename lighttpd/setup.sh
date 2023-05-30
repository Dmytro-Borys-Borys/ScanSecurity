#!/bin/bash

# Cargando settings generales
source "../config/config.txt"
set_scriptdir "$BASH_SOURCE"

# Comprobando si lighttpd está instalado
if command -v lighttpd &> /dev/null; then
    echo "lighttpd is installed"
else
    echo "lighttpd is not installed"

    # Instalando lighttpd php7.4-cgi
    sudo apt install lighttpd php7.4-cgi -y
    sudo lighttpd-enable-mod fastcgi
    sudo lighttpd-enable-mod fastcgi-php
fi
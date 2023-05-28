#!/bin/sh
sudo rm -v /etc/freeradius/3.0/clients.conf
sudo ln -sv $(pwd)/../freeradius/clients.conf  /etc/freeradius/3.0/clients.conf
sudo chown -Rv freerad:freerad /etc/freeradius/3.0/clients.conf

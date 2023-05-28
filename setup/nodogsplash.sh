#!/bin/sh

sudo apt update
sudo apt install linux-headers-$(uname -r)
sudo apt install build-essential debhelper devscripts git libmicrohttpd-dev -y
#!/bin/sh
while true; do
    if sudo hcidump --raw | grep -q "^> 02 40 20 09 00 05 00 04 00 1B 13 00 E9 00"; then
        python3 newcred.py
    fi
    sleep 11
done

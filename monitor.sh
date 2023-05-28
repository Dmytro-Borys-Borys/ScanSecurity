#!/bin/sh
while true; do
    while ! bluetoothctl connect FF:FF:E0:00:59:E2; do
        echo "Connection failed, retrying..."
    done

    if sudo hcidump --raw | grep -q "^> 02 40 20 09 00 05 00 04 00 1B 13 00 E9 00"; then
        ./newcred.sh
    fi
    sleep 10
done

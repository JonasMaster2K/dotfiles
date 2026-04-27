#!/bin/bash
echo "$@" >> /tmp/acpi-debug.log
user=$(loginctl list-sessions --no-legend | awk '{print $3}' | head -1)
uid=$(id -u "$user")
if [ "$4" = "00000001" ]; then
MODE="Tablet Mode"
else
MODE="Desktop Mode"
fi
sudo -u "$user" XDG_RUNTIME_DIR=/run/user/$uid DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "Display Mode" "$MODE"
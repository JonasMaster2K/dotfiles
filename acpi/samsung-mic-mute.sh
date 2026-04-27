#!/bin/bash
user=$(loginctl list-sessions --no-legend | awk '{print $3}' | head -1)
uid=$(id -u "$user")
sudo -u "$user" XDG_RUNTIME_DIR=/run/user/$uid pactl set-source-mute @DEFAULT_SOURCE@ toggle
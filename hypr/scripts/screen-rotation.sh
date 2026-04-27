#!/bin/bash

is_installed() {
    PACKAGE=$1
    paru -Qi $PACKAGE &>/dev/null
}

if is_installed "iio-sensor-proxy" && is_installed "iio-hyprland-git"; then
    echo "Starte iio-hyprland..."
    iio-hyprland &
else
    echo "Pakete iio-sensor-proxy oder iio-hyprland-git sind nicht installiert."
fi
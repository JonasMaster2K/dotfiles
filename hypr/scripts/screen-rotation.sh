#!/bin/bash

# Dem System kurz Zeit geben, falls es gerade erst hochgefahren ist
sleep 1

# Sicherstellen, dass wir im Home-Verzeichnis arbeiten
export PATH=$PATH:/usr/local/bin

# Monitor finden (mit Fallback, falls hyprctl noch nicht voll da ist)
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null)
[ -z "$MONITOR" ] && MONITOR=$(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null)

# Wenn kein Monitor gefunden wurde, Script beenden
[ -z "$MONITOR" ] && exit 0

# Start der Überwachung
# Wir nutzen 'stdbuf', um sicherzustellen, dass die Ausgabe sofort verarbeitet wird
monitor-sensor | stdbuf -oL grep "Accelerometer orientation changed:" | while read -r line; do
    orientation=$(echo "$line" | awk -F': ' '{print $2}')
    
    case "$orientation" in
        normal)    rot=0 ;;
        left-up)   rot=1 ;;
        bottom-up) rot=2 ;;
        right-up)  rot=3 ;;
        *) continue ;;
    esac

    # Native Lua-Befehle senden
    hyprctl eval "hl.monitor({ output = \"$MONITOR\", transform = $rot })"
    hyprctl eval "hl.config({ input = { touchdevice = { transform = $rot }, tablet = { transform = $rot } } })"
done
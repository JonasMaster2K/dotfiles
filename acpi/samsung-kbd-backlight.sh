#!/bin/bash
current=$(cat /sys/class/leds/samsung-galaxybook::kbd_backlight/brightness)
max=$(cat /sys/class/leds/samsung-galaxybook::kbd_backlight/max_brightness)
next=$(( (current + 1) % (max + 1) ))
echo $next > /sys/class/leds/samsung-galaxybook::kbd_backlight/brightness

#!/bin/bash
hyprpaper &
sleep 0.5

gcd() {
    local a=$1 b=$2
    while [ $b -ne 0 ]; do
        local t=$b; b=$((a%b)); a=$t
    done
    echo $a
}

tmpfile=$(mktemp)

mkdir -p $HOME/dotfiles/.cache/

hyprctl monitors -j | jq -r '.[] | "\(.name) \(.width) \(.height)"' | while read name w h; do
    gcd_val=$(gcd $w $h)
    ratio="$((w/gcd_val))x$((h/gcd_val))"
    wallpaper_dir="$HOME/dotfiles/assets/wallpaper_${ratio}"
    [ ! -d "$wallpaper_dir" ] && echo "Kein Ordner: $wallpaper_dir" >&2 && continue
    wall=$(ls "$wallpaper_dir" | shuf -n1)
    full_path="$wallpaper_dir/$wall"
    echo "$name $full_path" >> "$tmpfile"
done

sleep 0.3

first=true
while read name full_path; do
    if $first; then
        ln -sf "$full_path" "$HOME/dotfiles/.cache/current_wallpaper"
        first=false
    fi
    hyprctl hyprpaper wallpaper "$name,$full_path"
done < "$tmpfile"

rm "$tmpfile"
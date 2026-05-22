-- ── Autostart ─────────────────────────────────────────────
hl.on("hyprland.start", function ()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprlock")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("swayosd-server")
    
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("bash -c 'sleep 1 && hyprsunset'")
    hl.exec_cmd("bash -c 'sleep 1 && bash ~/dotfiles/hypr/scripts/wallpaper.sh'")
    hl.exec_cmd("bash -c 'sleep 2 && bash ~/dotfiles/hypr/scripts/screen-rotation.sh'")

    hl.exec_cmd("ags run ~/dotfiles/ags/app.tsx")

    hl.exec_cmd("bash -c 'sleep 4 && easyeffects --hide-window --service-mode'")
end)

-- ── Environment ───────────────────────────────────────────
hl.env( "XDG_CURRENT_DESKTOP", "Hyprland")
hl.env( "XDG_SESSION_TYPE", "wayland")
hl.env( "XDG_SESSION_DESKTOP", "Hyprland")
hl.env( "GTK_THEME", "Tokyonight-Dark")
hl.env( "HYPRCURSOR_THEME", "Nordzy-cursors" )
hl.env( "XCURSOR_THEME",    "Nordzy-cursors" )
hl.env( "XCURSOR_SIZE",     "24" )
-- ── Window rules ──────────────────────────────────────────

-- Suppress maximize/minimize events globally
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix XWayland dragging issues
hl.window_rule({
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- ── Tags ──────────────────────────────────────────────────

-- Default opacity tag for all windows
hl.window_rule({ match = { class = ".*" }, tag = "+default-opacity" })

-- Terminal
hl.window_rule({ match = { class = "kitty|Alacritty|com.mitchellh.ghostty" }, tag = "+terminal" })

-- Browser
hl.window_rule({ match = { class = "(google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium" }, tag = "+chromium-based-browser" })
hl.window_rule({ match = { class = "[fF]irefox|zen|librewolf" }, tag = "+firefox-based-browser" })
hl.window_rule({ match = { class = "chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default" }, tag = "-chromium-based-browser" })

-- No opacity
hl.window_rule({ match = { tag = "chromium-based-browser" }, tag = "+no-opacity" })
hl.window_rule({ match = { tag = "firefox-based-browser" }, tag = "+no-opacity" })
hl.window_rule({ match = { class = "chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default" }, tag = "+no-opacity" })
hl.window_rule({ match = { class = "zoom|vlc|mpv|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.inkscape.Inkscape|gimp|krita" }, tag = "+no-opacity" })
hl.window_rule({ match = { tag = "no-opacity" }, tag = "-default-opacity" })
hl.window_rule({ match = { tag = "terminal" }, tag = "-default-opacity" })

-- Floating / centered windows
hl.window_rule({ match = { class = "Share|localsend|org.gnome.Calculator|io.github.JonasMaster2K.dotfiles.installer" }, tag = "+float-center" })
hl.window_rule({ match = { title = "Export Image as PNG|Preferences|Open Folder" }, tag = "+float-center" })
hl.window_rule({
    match = {
        class = "xdg-desktop-portal-gtk|sublime_text|DesktopEditors|thunar",
        title = "Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to (?:open|save).*|[Cc]hoose.*",
    },
    tag = "+floating-window",
})
hl.window_rule({ match = { class = "^Bitwarden$" }, tag = "+floating-window" })

-- Misc tags (pass-through, used in other rules)
hl.window_rule({ match = { tag = "noidle" }, tag = "+noidle" })
hl.window_rule({ match = { tag = "pop" }, tag = "+pop" })

-- ── Opacity ───────────────────────────────────────────────
hl.window_rule({ match = { tag = "default-opacity" }, opacity = "0.9 override 0.8 override" })
hl.window_rule({ match = { tag = "terminal" },         opacity = "0.9 override 0.8 override" })
hl.window_rule({ match = { tag = "chromium-based-browser" }, opacity = "1.0 override 0.97 override" })
hl.window_rule({ match = { tag = "firefox-based-browser" }, opacity = "1.0 override 0.97 override" })
hl.window_rule({ match = { tag = "no-opacity" }, opacity = "1.0 override 1.0 override" })

-- ── Floating & Layout ─────────────────────────────────────
hl.window_rule({ match = { tag = "float-center" }, float = true, center = true })
hl.window_rule({ match = { tag = "floating-window" }, float = true, center = true })
hl.window_rule({ match = { tag = "chromium-based-browser" }, tile = true })

-- Sizes
hl.window_rule({ match = { class = "localsend" }, size = { 1100, 700 } })
hl.window_rule({ match = { title = "^Preferences" }, size = { 800, 600 } })
hl.window_rule({ match = { title = "^Open Folder" }, size = { 800, 600 } })
hl.window_rule({ match = { tag = "floating-window" }, size = { 875, 600 } })

-- ── Special Workspaces ────────────────────────────────────
hl.window_rule({ match = { class = "[Ss]potify" }, workspace = "special:spotify" })

-- ── Misc ──────────────────────────────────────────────────
hl.window_rule({ match = { tag = "pop" }, rounding = 8 })
hl.window_rule({ match = { tag = "noidle" }, idle_inhibit = "always" })
hl.window_rule({ match = { class = "^Bitwarden$" }, no_screen_share = true })


hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, blur = true, blur_popups = true})
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, ignore_alpha = 0.2})
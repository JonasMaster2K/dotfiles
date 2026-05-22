-- ── Definitions ───────────────────────────────────────────
local mod        = "SUPER"
local terminal   = "kitty"
local browser    = "zen-browser"
local explorer   = "thunar"
local launcher   = "wofi --show drun"
local editor     = "codium"
local notes      = "obsidian"
local mail       = "thunderbird"
local musicplayer = "spotify"
local lockscreen = "hyprlock"
local osdclient  = 'swayosd-client --monitor "$(hyprctl monitors -j | jq -r \'.[] | select(.focused == true).name\')"'

-- ── Apps ──────────────────────────────────────────────────
hl.bind(mod .. " + T",       hl.dsp.exec_cmd(terminal),   { description = "Launch terminal" })
hl.bind(mod .. " + B",       hl.dsp.exec_cmd(browser),    { description = "Launch browser" })
hl.bind(mod .. " + E",       hl.dsp.exec_cmd(explorer),   { description = "Launch explorer" })
hl.bind(mod .. " + SPACE",   hl.dsp.exec_cmd(launcher),   { description = "Launch launcher" })
hl.bind(mod .. " + C",       hl.dsp.exec_cmd(editor),     { description = "Launch editor" })
hl.bind(mod .. " + N",       hl.dsp.exec_cmd(notes),      { description = "Launch notes" })
hl.bind(mod .. " + I",       hl.dsp.exec_cmd(mail),       { description = "Launch email" })
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("pgrep -x " .. musicplayer .. " || " .. musicplayer), { description = "Launch musicplayer" })
hl.bind(mod .. " + L",       hl.dsp.exec_cmd(lockscreen), { description = "Lock screen" })
hl.bind(mod .. " + H", hl.dsp.exec_cmd("ags -i desktop-shell request home-menu"), { description = "Toggle home menu" })

-- ── Special Workspaces ────────────────────────────────────
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mod .. " + S",        hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mod .. " + M",        hl.dsp.workspace.toggle_special("spotify"))

-- ── Window Management ─────────────────────────────────────
hl.bind("ALT + F4",          hl.dsp.window.close())
hl.bind(mod .. " + Q",       hl.dsp.window.close())
hl.bind(mod .. " + F",       hl.dsp.window.fullscreen({ mode = 0 }),  { description = "Fullscreen" })
hl.bind(mod .. " + D",       hl.dsp.window.fullscreen({ mode = 1 }),  { description = "Maximize" })
hl.bind(mod .. " + P",       hl.dsp.window.pin(),                     { description = "Pin window" })
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })

-- Move focus
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Swap windows
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Move/resize with mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

-- Resize with keyboard
hl.bind(mod .. " + comma",       hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
hl.bind(mod .. " + period",      hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })
hl.bind(mod .. " + numbersign",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
hl.bind(mod .. " + plus",        hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })

-- Cycle windows
hl.bind("ALT + TAB",       hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ prev = true }))

-- Workspace scroll
hl.bind(mod .. " + mouse_down",  hl.dsp.focus({workspace = "e-1"}))
hl.bind(mod .. " + mouse_up",    hl.dsp.focus({workspace = "e+1"}))
hl.bind(mod .. " + TAB",         hl.dsp.focus({workspace = "e+1"}))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({workspace = "e+1"}))
hl.bind(mod .. " + CTRL + TAB",  hl.dsp.focus({workspace = "e-1"}))

-- ── Groups ────────────────────────────────────────────────
-- hl.bind(mod .. " + G",              hl.dsp.group.toggle(),                         { description = "Toggle grouping" })
-- hl.bind(mod .. " + ALT + G",        hl.dsp.group.move_out(),                       { description = "Move out of group" })
-- hl.bind(mod .. " + ALT + left",     hl.dsp.group.move_into({ direction = "l" }),   { description = "Move into group left" })
-- hl.bind(mod .. " + ALT + right",    hl.dsp.group.move_into({ direction = "r" }),   { description = "Move into group right" })
-- hl.bind(mod .. " + ALT + up",       hl.dsp.group.move_into({ direction = "u" }),   { description = "Move into group up" })
-- hl.bind(mod .. " + ALT + down",     hl.dsp.group.move_into({ direction = "d" }),   { description = "Move into group down" })
-- hl.bind(mod .. " + ALT + TAB",      hl.dsp.group.change_active({ dir = "f" }),     { description = "Next in group" })
-- hl.bind(mod .. " + ALT + SHIFT + TAB", hl.dsp.group.change_active({ dir = "b" }), { description = "Prev in group" })
-- hl.bind(mod .. " + CTRL + left",    hl.dsp.group.change_active({ dir = "b" }),     { description = "Group focus left" })
-- hl.bind(mod .. " + CTRL + right",   hl.dsp.group.change_active({ dir = "f" }),     { description = "Group focus right" })
-- hl.bind(mod .. " + ALT + mouse_down", hl.dsp.group.change_active({ dir = "f" }),   { description = "Next in group" })
-- hl.bind(mod .. " + ALT + mouse_up",   hl.dsp.group.change_active({ dir = "b" }),   { description = "Prev in group" })
-- hl.bind(mod .. " + ALT + code:10", hl.dsp.group.change_active({ index = 1 }), { description = "Switch to group window 1" })
-- hl.bind(mod .. " + ALT + code:11", hl.dsp.group.change_active({ index = 2 }), { description = "Switch to group window 2" })
-- hl.bind(mod .. " + ALT + code:12", hl.dsp.group.change_active({ index = 3 }), { description = "Switch to group window 3" })
-- hl.bind(mod .. " + ALT + code:13", hl.dsp.group.change_active({ index = 4 }), { description = "Switch to group window 4" })
-- hl.bind(mod .. " + ALT + code:14", hl.dsp.group.change_active({ index = 5 }), { description = "Switch to group window 5" })

-- ── Workspaces ────────────────────────────────────────────
for i = 1, 9 do
    hl.bind(mod .. " + " .. i,                   hl.dsp.focus({workspace = i}))
    hl.bind(mod .. " + SHIFT + " .. i,           hl.dsp.window.move({ workspace = i, follow = true }))
end
hl.bind(mod .. " + 0",              hl.dsp.focus({workspace = 10}))
hl.bind(mod .. " + SHIFT + 0",      hl.dsp.window.move({ workspace = 10, follow = true }))

-- ── Fn-Keys ───────────────────────────────────────────────

-- Caps-Lock
hl.bind("Caps_Lock", hl.dsp.exec_cmd("swayosd-client --caps-lock"))

-- Volume
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(osdclient .. " --output-volume raise"),       { description = "Volume up",           repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(osdclient .. " --output-volume lower"),       { description = "Volume down",         repeating = true, locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(osdclient .. " --output-volume mute-toggle"), { description = "Mute",                repeating = true, locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(osdclient .. " --input-volume mute-toggle"),  { description = "Mute microphone",     repeating = true, locked = true })
-- Precise 1% volume
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd(osdclient .. " --output-volume +1"), { description = "Volume up precise",   repeating = true, locked = true })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd(osdclient .. " --output-volume -1"), { description = "Volume down precise",  repeating = true, locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(osdclient .. " --brightness raise"), { description = "Brightness up",       repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osdclient .. " --brightness lower"), { description = "Brightness down",     repeating = true, locked = true })
-- Precise 1% brightness
hl.bind("ALT + XF86MonBrightnessUp",   hl.dsp.exec_cmd(osdclient .. " --brightness +1"), { description = "Brightness up precise",   repeating = true, locked = true })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd(osdclient .. " --brightness -1"), { description = "Brightness down precise",  repeating = true, locked = true })

-- Media keys
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(osdclient .. " --playerctl play-pause"), { description = "Play/Pause", locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(osdclient .. " --playerctl play-pause"), { description = "Pause",      locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(osdclient .. " --playerctl next"),        { description = "Next track", locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(osdclient .. " --playerctl previous"),    { description = "Previous track", locked = true })

-- ── Screenshot ────────────────────────────────────────────
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%F_%T).png'))

-- ── Laptop Lid ────────────────────────────────────────────
hl.bind("switch:Lid Switch", hl.dsp.dpms({ action = "disable" }), { locked = true })
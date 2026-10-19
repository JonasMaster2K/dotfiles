local laptopMonitor = {
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = 1.25,
    disabled = false,
}
local desktopMonitor = {
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto",
    scale = 1.0,
    disabled = false,
}

hl.monitor(laptopMonitor)
hl.monitor(desktopMonitor)

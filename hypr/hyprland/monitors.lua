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

function disableLaptopMonitor()
    hl.monitor({
        output = laptopMonitor.output, 
        disabled = true ,
    })
end

function enableLaptopMonitor()
    hl.monitor(laptopMonitor)
end

-- Close lid
hl.bind("switch:on:Lid Switch", disableLaptopMonitor, { locked = true })
-- Open lid
hl.bind("switch:off:Lid Switch", enableLaptopMonitor, { locked = true })

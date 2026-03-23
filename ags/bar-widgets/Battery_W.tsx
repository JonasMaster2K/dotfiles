import { Gtk } from "ags/gtk4"
import Battery from "gi://AstalBattery"
import BatteryPopup from "../popup-menus/Battery_Popup"

const formatTime = (seconds: number) => {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    return h > 0 ? `${h}h ${m}m` : `${m}m`
}

export default function BatteryWidget(): Gtk.Widget | null {
    const upower = Battery.UPower.new()
    const devices = upower.get_devices()
    const battery = devices.find(d => d.nativePath?.includes("BAT")) ?? Battery.get_default()

    if (!battery.isPresent) return null

    const icon = new Gtk.Image({ icon_name: battery.batteryIconName })

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
        visible: battery.isPresent,
    })
    btn.set_child(icon)

    const popover = BatteryPopup(battery)
    popover.set_parent(btn)

    // FUNCTIONALITY ==========================================
    const update = () => {
        icon.icon_name = battery.batteryIconName
        const pct = battery.percentage

        btn.css_classes = [
            "statusbar-widget",
            pct < 0.2 ? "battery--critical" :
            pct < 0.4 ? "battery--low" :
            battery.charging ? "battery--charging" : "",
        ].filter(Boolean)

        const pct_rounded = Math.round(pct * 100) + "%"
        const time = battery.charging
            ? `⚡ ${formatTime(battery.get_time_to_full())}`
            : `${formatTime(battery.get_time_to_empty())} left`
        btn.tooltip_text = `${pct_rounded} — ${time}`
    }

    update()
    battery.connect("notify::battery-icon-name", update)
    battery.connect("notify::percentage",        update)
    battery.connect("notify::charging",          update)
    battery.connect("notify::time-to-empty",     update)
    battery.connect("notify::time-to-full",      update)

    btn.connect("clicked", () => popover.popup())

    return btn
}
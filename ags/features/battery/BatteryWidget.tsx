import { Gtk } from "ags/gtk4"
import Battery from "gi://AstalBattery"
import IconButton from "../../components/BarButton"
import BatteryPopup from "./BatteryPopup"
import formatTime from "../../utils/formatTime"

export default function BatteryWidget(): Gtk.Widget | null {
    const upower = Battery.UPower.new()
    const devices = upower.get_devices()
    const battery = devices.find(d => d.nativePath?.includes("BAT")) ?? Battery.get_default()

    if (!battery.isPresent) return null

    const btn = new IconButton({iconName: "battery-level-10"})
    btn.visible = battery.isPresent

    const popover = BatteryPopup(battery)
    popover.set_parent(btn)

    // FUNCTIONALITY ==========================================
    const update = () => {
        console.log("update called:", battery.batteryIconName)
        btn.icon.icon_name = battery.batteryIconName
        const pct = battery.percentage
        
        const display_pct = pct <= 1 ? Math.round(pct * 100) : Math.round(pct)
        const pct_rounded = display_pct + "%"
        
        const time = battery.charging
            ? `⚡ ${formatTime(battery.get_time_to_full())}`
            : `${formatTime(battery.get_time_to_empty())} left`
        btn.tooltip_text = `${pct_rounded} — ${time}`

        // Der Button behält IMMER nur seine Standard-Bar-Klasse
        btn.set_css_classes(["bar__btn"])

        // Standard-Klasse für das Icon (wichtig für GTK-Images)
        const iconClasses = ["image"]

        // Logik für die Icon-Farbe
        if (battery.charging) {
            // Wenn das Ladekabel angeschlossen ist, wird es grün
            iconClasses.push("battery-icon--ok")
        } else {
            // Wenn es entlädt, prüfen wir die Schwellenwerte
            if (display_pct <= 10) {
                iconClasses.push("battery-icon--err")
            } else if (display_pct <= 30) {
                iconClasses.push("battery-icon--warn")
            }
        }

        // Weist die Klassen exakt dem Icon zu
        btn.icon.set_css_classes(iconClasses)
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
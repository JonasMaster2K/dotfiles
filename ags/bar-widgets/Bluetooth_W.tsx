import { Gtk } from "ags/gtk4"
import AstalBluetooth from "gi://AstalBluetooth"
import BluetoothPopup from "../popup-menus/Bluetooth_Popup"

export default function BluetoothWidget(): Gtk.Widget {
    const bluetooth = AstalBluetooth.get_default()

    const icon = new Gtk.Image({
        icon_name: bluetooth.isPowered ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic",
    })

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
    })
    btn.set_child(icon)

    const popupMenu = BluetoothPopup(bluetooth)
    popupMenu.set_parent(btn)

    const rightClick = new Gtk.GestureClick({ button: 3 })
    btn.add_controller(rightClick)
    rightClick.connect("pressed", () => { bluetooth.toggle() })

    bluetooth.connect("notify::is-powered", () => {
        icon.icon_name = bluetooth.isPowered ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
    })

    btn.connect("clicked", () => popupMenu.popup())

    return btn
}
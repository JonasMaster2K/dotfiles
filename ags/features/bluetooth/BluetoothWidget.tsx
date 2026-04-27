import { Gtk } from "ags/gtk4"
import AstalBluetooth from "gi://AstalBluetooth"
import TaskBarIconButton from "../../components/BarButton"
import BluetoothPopup from "./BluetoothPopup"

export default function BluetoothWidget(): Gtk.Widget {
    const bluetooth = AstalBluetooth.get_default()

    const btn = new TaskBarIconButton({iconName: bluetooth.isPowered ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"})

    const popupMenu = BluetoothPopup(bluetooth)
    popupMenu.set_parent(btn)

    const rightClick = new Gtk.GestureClick({ button: 3 })
    btn.add_controller(rightClick)
    rightClick.connect("pressed", () => { bluetooth.toggle() })

    bluetooth.connect("notify::is-powered", () => {
        btn.icon.icon_name = bluetooth.isPowered ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
    })

    btn.connect("clicked", () => popupMenu.popup())

    return btn
}
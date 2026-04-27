import { Gtk } from "ags/gtk4"
import AstalTray from "gi://AstalTray?version=0.1"
import TaskBarIconButton from "../../components/BarButton"
import SystemTrayPopup from "./TrayPopup"

const tray = AstalTray.get_default()

export default function SystemTrayWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({ iconName: "arrow-down-symbolic" })
    const popupMenu = SystemTrayPopup()
    popupMenu.set_parent(btn)

    const update = () => {
        btn.visible = tray.get_items().length > 0
    }

    update()
    tray.connect("item-added",   update)
    tray.connect("item-removed", update)

    btn.connect("clicked", () => popupMenu.popup())
    return btn
}
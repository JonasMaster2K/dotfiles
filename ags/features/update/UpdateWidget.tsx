import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import { execAsync } from "ags/process"
import TaskBarIconButton from "../../components/BarButton"
import UpdatePopup from "./UpdatePopup"

export default function UpdateWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({iconName: "update-urgency-low-symbolic"})

    const popover = UpdatePopup()

    btn.connect("realize", () => popover.set_parent(btn))
    btn.connect("clicked", () => popover.popup())

    return btn
}
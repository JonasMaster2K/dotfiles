import { Gtk } from "ags/gtk4"
import TaskBarIconButton from "../components/TaskBarIconButton"
import HomeMenuPopup from "../popup-menus/HomeMenu_Popup"

export default function HomeMenuWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton("user-home-symbolic")

    const popover = HomeMenuPopup()
    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    return btn
}
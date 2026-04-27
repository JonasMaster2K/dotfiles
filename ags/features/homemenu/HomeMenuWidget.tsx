import { Gtk } from "ags/gtk4"
import TaskBarIconButton from "../../components/BarButton"
import HomeMenuPopup from "./HomeMenuPopup"

export default function HomeMenuWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({iconName: "user-home-symbolic"})

    const popover = HomeMenuPopup()
    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    return btn
}
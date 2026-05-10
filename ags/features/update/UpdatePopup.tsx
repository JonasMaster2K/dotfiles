import { Gtk } from "ags/gtk4"
import Popup from "../../components/Popup"
import PomodoroTimer from "../../services/PomodoroTimer"

export default function MediaPlayerPopup(): Popup {
    const popup = new Popup({ minWidth: 360, header: false, footer: false })

    const todo = new Gtk.Label({
        label: "TODO",
        css_classes: ["text--xl"]
    })
    popup.body.append(todo)

    return popup
}
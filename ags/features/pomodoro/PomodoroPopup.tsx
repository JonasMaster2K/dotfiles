import { Gtk } from "ags/gtk4"
import Popup from "../../components/Popup"
import PomodoroTimer from "../../services/PomodoroTimer"

export default function MediaPlayerPopup(getPlayer: () => PomodoroTimer | null): Popup {
    const popup = new Popup({ minWidth: 360, header: false, footer: false })

    const todo = new Gtk.Label({
        label: "TODO",
        css_classes: ["text--xl"]
    })
    popup.body.append(todo)
    const scale = new Gtk.Scale({
        orientation: Gtk.Orientation.HORIZONTAL,
        hexpand: true,
        vexpand: true,
        adjustment: new Gtk.Adjustment({
            lower: 0,
            upper: 100,
            step_increment: 1,
            page_increment: 10,
            value: 50
        }),
        css_classes: ["scale--default"],
    })
    popup.body.append(scale)

    return popup
}
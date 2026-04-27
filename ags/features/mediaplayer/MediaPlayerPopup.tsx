import { Gtk } from "ags/gtk4"
import AstalMpris from "gi://AstalMpris?version=0.1"
import Popup from "../../components/Popup"

export default function MediaPlayerPopup(getPlayer: () => AstalMpris.Player | null): Popup {
    const popup = new Popup({ minWidth: 360, header: false, footer: false })

    const todo = new Gtk.Label({
        label: "TODO",
        css_classes: ["text--xl"]
    })
    popup.body.append(todo)

    return popup
}
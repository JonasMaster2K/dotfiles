import { Gtk } from "ags/gtk4"
import NotificationFeed from "../components/NotificationFeed"

const feed = NotificationFeed()

const content = new Gtk.Box({
    css_classes: ["popover--panel"],
    orientation: Gtk.Orientation.VERTICAL,
})
content.append(feed)

const popover = new Gtk.Popover({
    css_classes: ["notification-popover"],
    has_arrow: false,
    width_request: 380,
})
popover.set_child(content)
popover.set_offset(0, 10)

export default function NotificationPopup(): Gtk.Popover {
    return popover
}
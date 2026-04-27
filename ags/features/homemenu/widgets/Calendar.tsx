import { Gtk } from "ags/gtk4"

export default function CalendarPage(): Gtk.Widget {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4 })
    box.append(new Gtk.Calendar({ css_classes: ["home-menu__cal"] }))
    return box
}
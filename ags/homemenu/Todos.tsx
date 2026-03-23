import { Gtk } from "ags/gtk4"

export default function TodosPage(): Gtk.Widget {
    return new Gtk.Label({ label: "Todos – TODO" })
}
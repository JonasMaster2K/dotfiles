import { Gtk } from "ags/gtk4"

export default function HomeMenuQuickstart(): Gtk.Widget {
    return new Gtk.Label({ label: "Quickstart – TODO" })
}
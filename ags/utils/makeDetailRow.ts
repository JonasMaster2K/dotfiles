import { Gtk } from "ags/gtk4"

export default function makeDetailRow(key: string, value = "") {
    const row = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true })
    const k = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.START, hexpand: true, label: key })
    const v = new Gtk.Label({ css_classes: ["label--mono-sm"], halign: Gtk.Align.END, label: value })
    row.append(k)
    row.append(v)
    return { row, v }
}
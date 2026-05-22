import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import BarWidget from "../../components/BarWidget"

export default function ClockWidget(): Gtk.Widget {
    let enable_seconds = false

    const widget = new BarWidget()

    const dateLabel = new Gtk.Label({
        css_classes: ["clock__date"],
        valign: Gtk.Align.CENTER,
        yalign: 0.5,
    })

    const timeLabel = new Gtk.Label({
        css_classes: ["clock__time"],
        valign: Gtk.Align.CENTER,
        yalign: 0.5,
    })

    const ampmLabel = new Gtk.Label({
        css_classes: ["clock__ampm"],
        valign: Gtk.Align.BASELINE_FILL,
        yalign: 0.5,
    })

    const timeBox = new Gtk.Box({ spacing: 2, valign: Gtk.Align.CENTER })
    timeBox.append(timeLabel)
    timeBox.append(ampmLabel)

    widget.content.spacing = 12
    widget.content.append(dateLabel)
    widget.content.append(timeBox)

    const update = () => {
        const now = GLib.DateTime.new_now_local()
        dateLabel.label = now.format("%a %b %-d") ?? ""
        if(enable_seconds) timeLabel.label = now.format("%I:%M:%S") ?? ""
        else timeLabel.label = now.format("%I:%M") ?? ""
        ampmLabel.label = now.format("%p")?.toUpperCase() ?? ""
    }

    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => { update(); return GLib.SOURCE_CONTINUE })

    return widget
}
import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import BarWidget from "../../components/BarWidget"

export default function ClockWidget(): Gtk.Widget {
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

    const secLabel = new Gtk.Label({
        css_classes: ["clock__sec"],
        valign: Gtk.Align.BASELINE_FILL,
        yalign: 0.5,
    })

    const timeBox = new Gtk.Box({ spacing: 2, valign: Gtk.Align.CENTER })
    timeBox.append(timeLabel)
    timeBox.append(ampmLabel)
    timeBox.append(secLabel)

    widget.content.spacing = 4
    widget.content.append(dateLabel)
    widget.content.append(new Gtk.Separator({ css_classes: ["clock__sep"] }))
    widget.content.append(timeBox)

    const update = () => {
        const now = GLib.DateTime.new_now_local()
        dateLabel.label = now.format("%a, %-d. %b") ?? ""
        timeLabel.label = now.format("%I:%M") ?? ""
        ampmLabel.label = now.format("%p")?.toLowerCase() ?? ""
        secLabel.label  = now.format("%S") ?? ""
    }

    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => { update(); return GLib.SOURCE_CONTINUE })

    return widget
}
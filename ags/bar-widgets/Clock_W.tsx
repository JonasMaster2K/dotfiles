import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

export default function ClockWidget(): Gtk.Widget {
    const box = new Gtk.Box({
        css_classes: ["statusbar-widget__no-hover"],
        valign: Gtk.Align.CENTER,
        spacing: 8 
    })

    const dateBox = new Gtk.Box({ 
        spacing: 4, 
        valign: Gtk.Align.CENTER 
    })
    box.append(dateBox)

    const dateLabel = new Gtk.Label({ 
        css_classes: ["text--md", "text--primary"],
        valign: Gtk.Align.CENTER,
    })
    dateBox.append(dateLabel)

    const timeBox = new Gtk.Box({ 
        spacing: 4, 
        valign: Gtk.Align.CENTER 
    })
    box.append(timeBox)
    
    const timeLabel = new Gtk.Label({ 
        css_classes: ["text--md", "text--primary"],
        valign: Gtk.Align.CENTER,
    })
    timeBox.append(timeLabel)

    const update = () => {
        const now = GLib.DateTime.new_now_local()
        timeLabel.label = now.format("%I:%M %p") ?? ""
        dateLabel.label = now.format("%a, %-d. %b ") ?? ""
    }
    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => { update(); return GLib.SOURCE_CONTINUE })

    return box
}
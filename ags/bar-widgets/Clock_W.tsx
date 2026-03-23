import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import CenterPopup from "../popup-menus/Center_Popup"

export default function ClockWidget(): Gtk.Widget {
    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
    })

    const popover = CenterPopup()
    popover.set_parent(btn)

    const box = new Gtk.Box({ 
        spacing: 8 
    })
    btn.set_child(box)

    const dateBox = new Gtk.Box({ 
        spacing: 4, 
        valign: Gtk.Align.CENTER 
    })
    box.append(dateBox)

    const dateIcon = new Gtk.Image({ 
        css_classes: ["icon--secondary"], 
        icon_name: "x-office-calendar-symbolic", 
        pixel_size: 14 
    })
    dateBox.append(dateIcon)

    const dateLabel = new Gtk.Label({ 
        css_classes: ["text--md", "text--primary"] 
    })
    dateBox.append(dateLabel)

    const timeBox = new Gtk.Box({ 
        spacing: 4, 
        valign: Gtk.Align.CENTER 
    })
    box.append(timeBox)

    const timeIcon = new Gtk.Image({ 
        css_classes: ["icon--secondary"], 
        icon_name: "alarm-symbolic", 
        pixel_size: 14 
    })
    timeBox.append(timeIcon)
    
    const timeLabel = new Gtk.Label({ 
        css_classes: ["text--md", "text--primary"] 
    })
    timeBox.append(timeLabel)

    const update = () => {
        const now = GLib.DateTime.new_now_local()
        timeLabel.label = now.format("%I:%M %p") ?? ""
        dateLabel.label = now.format("%a, %-d. %b") ?? ""
    }
    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => { update(); return GLib.SOURCE_CONTINUE })

    btn.connect("clicked", ()=>{popover.popup()})

    return btn
}
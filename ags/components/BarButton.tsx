import { Gtk } from "ags/gtk4"
import GObject from "gi://GObject"

interface BarButtonOptions {
    iconName?: string
    minWidth?: number
}

export default class BarButton extends Gtk.Button {
    static { GObject.registerClass(this) }

    public icon:    Gtk.Image
    public content: Gtk.Box
    public extra:   Gtk.Box

    constructor({ iconName = "", minWidth = 35 }: BarButtonOptions = {}) {
        super({
            css_classes: ["bar__btn"],
            valign: Gtk.Align.FILL,
            width_request: minWidth,
        })
        this.content = new Gtk.Box({
            valign: Gtk.Align.CENTER,
            halign: Gtk.Align.CENTER,
            spacing: 6,
        })
        this.icon = new Gtk.Image({
            valign: Gtk.Align.CENTER,
            halign: Gtk.Align.CENTER,
            hexpand: true,
            icon_name: iconName,
            pixel_size: 18,
        })
        this.extra = new Gtk.Box({ spacing: 2 })
        if (iconName) this.content.append(this.icon)
        this.set_child(this.content)
    }
}
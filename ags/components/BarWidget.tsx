import { Gtk } from "ags/gtk4"
import GObject from "gi://GObject"

interface BarWidgetOptions {
    iconName?: string
    minWidth?: number
    spacing?: number
}

export default class BarWidget extends Gtk.Box {
    static { GObject.registerClass(this) }

    public icon:    Gtk.Image
    public content: Gtk.Box

    constructor({ iconName = "", minWidth = -1, spacing = 6 }: BarWidgetOptions = {}) {
        super({
            css_classes: ["bar__widget"],
            valign: Gtk.Align.FILL,
        })
        this.content = new Gtk.Box({
            width_request: minWidth,
            valign: Gtk.Align.CENTER,
            spacing,
        })
        this.icon = new Gtk.Image({
            valign: Gtk.Align.CENTER,
            icon_name: iconName,
            pixel_size: 18,
        })
        if (iconName) this.content.append(this.icon)
        this.append(this.content)
    }
}
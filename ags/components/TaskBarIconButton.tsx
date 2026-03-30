import { Gtk } from "ags/gtk4"
import GObject from "gi://GObject"

export default class TaskBarIconButton extends Gtk.Button {
    static { GObject.registerClass(this) }
    
    public icon: Gtk.Image
    public content: Gtk.Box
    public extra: Gtk.Box

    constructor(iconName: string) {
        super({
            css_classes: ["statusbar-widget"],
            valign: Gtk.Align.CENTER,
        })

        this.content = new Gtk.Box({
            width_request: 24,
            height_request: 20,
            homogeneous: true
        })

        this.icon = new Gtk.Image({
            valign: Gtk.Align.CENTER,
            icon_name: iconName,
            pixel_size: 16,
        })

        this.extra = new Gtk.Box({
            valign: Gtk.Align.CENTER,
            halign: Gtk.Align.CENTER,
            visible: false
        })

        this.content.append(this.icon)
        this.content.append(this.extra)
        this.set_child(this.content)
    }
}
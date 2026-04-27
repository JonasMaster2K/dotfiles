import { Gtk } from "ags/gtk4"
import GObject from "gi://GObject"

interface PopupOptions {
    minWidth?: number
    minHeight?: number
    offsetX?: number
    offsetY?: number
    header?: boolean
    footer?: boolean
}

export default class Popup extends Gtk.Popover {
    static { GObject.registerClass(this) }

    private revealer: Gtk.Revealer
    private content: Gtk.Box
    public header: Gtk.Box
    public body: Gtk.Box
    public footer: Gtk.Box
    public onOpen?: () => void
    public onClose?: () => void

    constructor({ minWidth = 450, minHeight = -1, offsetX = 0, offsetY = 10, header = true, footer = true }: PopupOptions = {}) {
        super({
            css_classes: ["popup"],
            has_arrow: false,
            autohide: true,
            width_request: minWidth,
            height_request: minHeight,
            position: Gtk.PositionType.BOTTOM,
        })
        this.set_offset(offsetX, offsetY)

        this.revealer = new Gtk.Revealer({
            transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
            transition_duration: 200,
            reveal_child: false,
        })
        this.set_child(this.revealer)

        this.content = new Gtk.Box({
            css_classes: ["popover--panel"],
            orientation: Gtk.Orientation.VERTICAL,
            hexpand: true,
            vexpand: true,
            spacing: 8,
        })
        this.revealer.set_child(this.content)

        this.header = new Gtk.Box({
            orientation: Gtk.Orientation.VERTICAL,
            hexpand: true,
            spacing: 4,
        })
        if (header) this.content.append(this.header)
        if (header) this.content.append(new Gtk.Separator({ css_classes: ["divider"] }))

        this.body = new Gtk.Box({
            orientation: Gtk.Orientation.VERTICAL,
            hexpand: true,
            vexpand: true,
            spacing: 4,
        })
        this.content.append(this.body)

        if (footer) this.content.append(new Gtk.Separator({ css_classes: ["divider"] }))
        this.footer = new Gtk.Box({
            orientation: Gtk.Orientation.VERTICAL,
            hexpand: true,
            spacing: 4,
        })
        if (footer) this.content.append(this.footer)

        this.connect("notify::visible", () => {
            if (this.visible) {
                this.onOpen?.()
                this.revealer.reveal_child = true
            } else {
                this.onClose?.()
                this.revealer.reveal_child = false
            }
        })
    }
}
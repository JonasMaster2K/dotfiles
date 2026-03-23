import { Gtk } from "ags/gtk4"

export interface ProgressCircleWidget extends Gtk.Overlay {
    fraction: number
}

export default function ProgressCircle(size: number = 28): ProgressCircleWidget {
    const canvas = new Gtk.DrawingArea({
        css_classes: ["circprog"],
        width_request: size,
        height_request: size,
        valign: Gtk.Align.CENTER,
        halign: Gtk.Align.CENTER,
    })

    let _fraction = 0

    const overlay = new Gtk.Overlay({
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    }) as ProgressCircleWidget

    Object.defineProperty(overlay, "fraction", {
        get: () => _fraction,
        set: (value: number) => {
            _fraction = Math.max(0, Math.min(1, value))
            canvas.queue_draw()
        },
    })

    canvas.set_draw_func((_: any, cr: any, w: number, h: number) => {
        const cx = w / 2, cy = h / 2, r = Math.min(w, h) / 2 - 2
        const start = -Math.PI / 2
        const end = start + _fraction * 2 * Math.PI

        cr.setSourceRGBA(0.17, 0.22, 0.30, 1)
        cr.setLineWidth(2.5)
        cr.arc(cx, cy, r, 0, 2 * Math.PI)
        cr.stroke()
        cr.setLineCap(1)

        if (_fraction > 0) {
            cr.setSourceRGBA(0.47, 0.69, 0.91, 1)
            cr.setLineWidth(2.5)
            cr.arc(cx, cy, r, start, end)
            cr.stroke()
        }
    })

    overlay.set_child(canvas)
    return overlay
}
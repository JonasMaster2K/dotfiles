import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import Gdk from "gi://Gdk?version=4.0"

export default function ColorPickerWidget(): Gtk.Widget {
    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
        tooltip_text: "Pick color",
    })
    btn.set_child(new Gtk.Image({ icon_name: "color-select-symbolic", pixel_size: 16 }))

    // FUNCTIONALITY ==========================================
    btn.connect("clicked", () => {
        btn.sensitive = false
        const [, pid] = GLib.spawn_async(
            null,
            ["hyprpicker", "-a"],
            null,
            GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.DO_NOT_REAP_CHILD,
            null
        )
        GLib.child_watch_add(GLib.PRIORITY_DEFAULT, pid!, () => {
            btn.sensitive = true
            Gdk.Display.get_default()!.get_clipboard().read_text_async(null, (_: any, res: any) => {
                try {
                    const color = Gdk.Display.get_default()!.get_clipboard().read_text_finish(res)
                    if (color?.startsWith("#")) {
                        btn.tooltip_text = `Copied: ${color}`
                        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
                            btn.tooltip_text = "Pick color"
                            return GLib.SOURCE_REMOVE
                        })
                    }
                } catch {}
            })
        })
    })

    return btn
}
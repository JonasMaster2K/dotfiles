import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

export default function PowerWidget(): Gtk.Widget {
    const home = GLib.get_home_dir()

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
        tooltip_text: "Power menu",
    })
    btn.set_child(new Gtk.Image({ icon_name: "system-shutdown-symbolic", pixel_size: 16 }))

    btn.connect("clicked", () => {
        GLib.spawn_command_line_async(`wlogout -b 6 -c 8 -r 8 -T 600 -B 600 -C ${home}/dotfiles/wlogout/style.css`)
    })

    return btn
}
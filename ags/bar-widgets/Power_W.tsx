import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import TaskBarIconButton from "../components/TaskBarIconButton"

export default function PowerWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton("system-shutdown-symbolic")

    const home = GLib.get_home_dir()
    const display = Gdk.Display.get_default()
    const monitor = display?.get_monitors().get_item(0) as Gdk.Monitor
    const height = monitor?.get_geometry().height ?? 1080
    const margin = Math.floor(height * 0.425)

    btn.connect("clicked", () => {
        GLib.spawn_command_line_async(`wlogout -b 5 -c 8 -r 8 -T ${margin} -B ${margin} -C ${home}/dotfiles/wlogout/style.css`)
    })

    return btn
}
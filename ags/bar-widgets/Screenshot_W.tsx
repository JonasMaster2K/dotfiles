import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import TaskBarIconButton from "../components/TaskBarIconButton"

export default function ScreenshotWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton("accessories-screenshot-symbolic")

    // FUNCTIONALITY ==========================================
    btn.connect("clicked", () => {
        btn.sensitive = false
        const timestamp = GLib.DateTime.new_now_local().format("%Y-%m-%d_%H-%M-%S")
        const path = `${GLib.get_home_dir()}/Pictures/Screenshots/${timestamp}.png`
        const [, pid] = GLib.spawn_async(
            null,
            ["bash", "-c", `grim -g "$(slurp)" ${path} && wl-copy < ${path}`],
            null,
            GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.DO_NOT_REAP_CHILD,
            null
        )
        GLib.child_watch_add(GLib.PRIORITY_DEFAULT, pid!, (_: any, status: number) => {
            btn.sensitive = true
            if (status === 0) {
                btn.icon.icon_name   = "emblem-ok-symbolic"
                btn.tooltip_text = `Saved: ${path}`
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
                    btn.icon.icon_name   = "accessories-screenshot-symbolic"
                    btn.tooltip_text = "Screenshot"
                    return GLib.SOURCE_REMOVE
                })
            }
        })
    })

    return btn
}
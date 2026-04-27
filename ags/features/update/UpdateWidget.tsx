import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import { execAsync } from "ags/process"
import TaskBarIconButton from "../../components/BarButton"
import UpdatePopup from "./UpdatePopup"

export default function UpdateWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({iconName: "update-high"})
    btn.visible = false
    btn.icon.pixelSize = 24

    const { popover, rebuildList } = UpdatePopup(() => checkUpdates())

    // ========================================================
    // FUNCTIONALITY
    // ========================================================
    const checkUpdates = async () => {
        try {
            const outExtra = (await execAsync(["bash", "-c", "{ checkupdates; } | sort -u"]).catch(() => "")).trim().split("\n").filter(Boolean)
            const outAur = (await execAsync(["bash", "-c", "{ paru -Qua; } | sort -u"]).catch(() => "")).trim().split("\n").filter(Boolean)
            const updates = outExtra.concat(outAur)
            const total = updates.length
            rebuildList(updates, outExtra.length)

            if (total > 0) {
                if (total <= 5)       btn.icon.iconName = "update-low"
                else if (total <= 10) btn.icon.iconName = "update-medium"
                else                  btn.icon.iconName = "update-high"
                btn.tooltip_text = `${total} updates available`
                btn.visible = true
            } else {
                btn.visible = false
            }
        } catch {
            btn.visible = false
        }
    }

    // Nach Popup-Close: 5 Min warten, dann neu checken
    popover.connect("notify::visible", () => {
        if (!popover.visible) {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5 * 60 * 1000, () => {
                checkUpdates()
                return GLib.SOURCE_REMOVE
            })
        }
    })

    // Initial nach 3s
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
        checkUpdates()
        return GLib.SOURCE_REMOVE
    })

    // Alle 30 Min wiederholen
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 30 * 60, () => {
        checkUpdates()
        return GLib.SOURCE_CONTINUE
    })

    btn.connect("realize", () => popover.set_parent(btn))
    btn.connect("clicked", () => popover.popup())

    return btn
}
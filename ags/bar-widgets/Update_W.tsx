import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import { execAsync } from "ags/process"
import UpdatePopup from "../popup-menus/Update_Popup"

export default function UpdateWidget(): Gtk.Widget {
    // STRUCTURE ==============================================
    const countLabel = new Gtk.Label({
        css_classes: ["label--count"],
        visible: false,
    })

    const barBox = new Gtk.Box({ spacing: 4, valign: Gtk.Align.CENTER })
    barBox.append(new Gtk.Image({ icon_name: "software-update-available-symbolic", pixel_size: 16 }))
    barBox.append(countLabel)

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
        visible: false,
    })
    btn.set_child(barBox)

    const { popover, rebuildList } = UpdatePopup()
    btn.connect("realize", () => popover.set_parent(btn))
    btn.connect("clicked", () => popover.popup())

    // FUNCTIONALITY ==========================================
    const checkUpdates = async () => {
        try {
            const out = await execAsync(["bash", "-c", "paru -Qu; true"]).catch(() => "")
            const updates = out.trim().split("\n").filter(Boolean)
            const total = updates.length
            rebuildList(updates)
            if (total > 0) {
                countLabel.label   = total.toString()
                countLabel.visible = true
                btn.tooltip_text   = `${total} updates available`
                btn.visible        = true
            } else {
                btn.visible        = false
                countLabel.visible = false
            }
        } catch {
            btn.visible = false
        }
    }

    // nach update alle re-checken
    popover.connect("notify::visible", () => {
        if (!popover.visible) {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5 * 60 * 1000, () => {
                checkUpdates()
                return GLib.SOURCE_REMOVE
            })
        }
    })

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
        checkUpdates()
        return GLib.SOURCE_REMOVE
    })

    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 30 * 60, () => {
        checkUpdates()
        return GLib.SOURCE_CONTINUE
    })

    return btn
}
import { Gtk } from "ags/gtk4"
import AstalNotifd from "gi://AstalNotifd?version=0.1"
import NotificationPopup from "../popup-menus/Notifications_Popup"

const notify = AstalNotifd.get_default()

export default function NotificationWidget(): Gtk.Widget {
    // STRUCTURE ==============================================
    const icon = new Gtk.Image({
        icon_name: "notification-symbolic",
        pixel_size: 16,
    })

    const countLabel = new Gtk.Label({
        css_classes: ["label--count"],
        label: "",
        visible: false,
    })

    const box = new Gtk.Box({ spacing: 4 })
    box.append(icon)
    box.append(countLabel)

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
    })
    btn.set_child(box)

    // POPOVER ================================================
    const popover = NotificationPopup()
    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    // FUNCTIONALITY ==========================================
    const update = () => {
        const n = notify.notifications
        icon.icon_name     = notify.dontDisturb
            ? "notifications-disabled-symbolic"
            : "notification-symbolic"
        countLabel.label   = n.length > 0 ? n.length.toString() : ""
        countLabel.visible = n.length > 0 && !notify.dontDisturb
        btn.tooltip_text   = notify.dontDisturb ? "Do not disturb" : n.length.toString()
    }

    notify.connect("notified",             update)
    notify.connect("resolved",             update)
    notify.connect("notify::dont-disturb", update)
    update()

    return btn
}
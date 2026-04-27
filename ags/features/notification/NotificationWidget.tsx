import { Gtk } from "ags/gtk4"
import AstalNotifd from "gi://AstalNotifd?version=0.1"
import TaskBarIconButton from "../../components/BarButton"
import NotificationPopup from "./NotificationPopup"

const notify = AstalNotifd.get_default()

export default function NotificationWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({iconName: "notification-symbolic"})

    // POPOVER ================================================
    const popover = NotificationPopup()
    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    // FUNCTIONALITY ==========================================
    const update = () => {
        const n = notify.notifications
        let tooltip: string

        if (notify.dontDisturb) {
            tooltip = "Do not disturb"
        } else if (n.length === 0) {
            tooltip = "No notifications"
        } else if (n.length === 1) {
            tooltip = "1 notification"
        } else {
            tooltip = `${n.length} notifications`
        }
        btn.icon_name     = notify.dontDisturb
            ? "notifications-disabled"
            : n.length > 0 ? "notification-active" 
            : "notification-inactive"
        btn.tooltip_text   = tooltip
    }

    notify.connect("notified",             update)
    notify.connect("resolved",             update)
    notify.connect("notify::dont-disturb", update)
    update()

    return btn
}
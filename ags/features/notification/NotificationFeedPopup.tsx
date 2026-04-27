import { Astal, Gtk } from "ags/gtk4"
import AstalNotifd from "gi://AstalNotifd"
import Notification from "../../components/Notification"
import GLib from "gi://GLib"
import Gdk from "gi://Gdk?version=4.0"

const POPUP_TIMEOUT = 5000

export default function NotificationPopupFeed() {
    const notifd = AstalNotifd.get_default()
    notifd.set_ignore_timeout(true)

    const monitors = Gdk.Display.get_default()!.get_monitors()

    const createWindowForMonitor = (monitor: Gdk.Monitor) => {
        const widgetMap = new Map<number, Gtk.Widget>()

        const list = new Gtk.Box({
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 5,
            margin_top: 6,
            margin_end: 6,
        })

        const win = new Astal.Window({
            css_classes: ["NotificationPopups"],
            gdkmonitor: monitor,
            visible: false,
            anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
            width_request: 400
        })
        win.set_child(list)

        const updateVisible = () => { win.visible = widgetMap.size > 0 }

        const scheduleRemoval = (id: number) => {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, POPUP_TIMEOUT, () => {
                widgetMap.get(id)?.unparent()
                widgetMap.delete(id)
                updateVisible()
                return GLib.SOURCE_REMOVE
            })
        }

        const notifiedHandler = notifd.connect("notified", (_: any, id: number, replaced: boolean) => {
            if (notifd.dontDisturb) return
            const n = notifd.get_notification(id)
            if (!n) return

            if (replaced && widgetMap.has(id)) {
                widgetMap.get(id)?.unparent()
                widgetMap.delete(id)
            }

            const widget = Notification({
                notification: n,
                isPopup: true,
                onMinimize: () => {
                    widgetMap.get(id)?.unparent()
                    widgetMap.delete(id)
                    updateVisible()
                },
                onDismiss: () => n.dismiss(),
            })
            widgetMap.set(id, widget)
            list.prepend(widget)
            updateVisible()
            scheduleRemoval(id)
        })

        const removeHandler = notifd.connect("resolved", (_: any, id: number) => {
            widgetMap.get(id)?.unparent()
            widgetMap.delete(id)
            updateVisible()
        })

        monitor.connect("invalidate", () => {
            notifd.disconnect(notifiedHandler)
            notifd.disconnect(removeHandler)
            win.destroy()
        })

        return win
    }

    for (let i = 0; i < monitors.get_n_items(); i++) {
        createWindowForMonitor(monitors.get_item(i) as Gdk.Monitor)
    }

    monitors.connect("items-changed", (_: any, pos: number, _removed: number, added: number) => {
        for (let i = pos; i < pos + added; i++) {
            createWindowForMonitor(monitors.get_item(i) as Gdk.Monitor)
        }
    })
}
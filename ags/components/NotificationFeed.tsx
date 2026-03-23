import Gtk from "gi://Gtk?version=4.0"
import AstalNotifd from "gi://AstalNotifd"
import Notification from "./Notification"

export default function NotificationFeed(): Gtk.Widget {
    const notifd = AstalNotifd.get_default()

    // == EMPTY STATE =======================================================
    const emptyBox = new Gtk.Box({
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 10,
        vexpand: true,
    })
    emptyBox.append(new Gtk.Image({
        css_classes: ["icon--tertiary"],
        iconName: "notifications-symbolic",
        pixelSize: 48,
    }))
    emptyBox.append(new Gtk.Label({
        css_classes: ["label--meta"],
        label: "No notifications",
    }))

    // == NOTIFICATION LIST =================================================
    const notificationList = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 5,
        valign: Gtk.Align.START,
    })

    const widgetMap = new Map<number, Gtk.Widget>()

    const updateStack = () => {
        stack.set_visible_child_name(widgetMap.size > 0 ? "list" : "empty")
        updateBottomBar()
    }

    notifd.connect("notified", (_, id) => {
        const n = notifd.get_notification(id)
        if (!n) return
        widgetMap.get(id)?.unparent()
        widgetMap.delete(id)
        const widget = Notification({
            notification: n,
            onDismiss: () => {
                widgetMap.delete(id)
                n.dismiss()
            },
        })
        widgetMap.set(id, widget)
        notificationList.prepend(widget)
        updateStack()
    })

    notifd.connect("resolved", (_, id) => {
        if (widgetMap.has(id)) {
            widgetMap.get(id)?.unparent()
            widgetMap.delete(id)
        }
        updateStack()
    })

    notifd.notifications.forEach(n => {
        const widget = Notification({ notification: n, onDismiss: () => n.dismiss() })
        widgetMap.set(n.id, widget)
        notificationList.append(widget)
    })

    // == STACK =============================================================
    const stack = new Gtk.Stack({
        transitionType: Gtk.StackTransitionType.CROSSFADE,
        transitionDuration: 150,
        hexpand: true,
        vexpand: true,
    })
    stack.add_named(emptyBox, "empty")

    const scrollable = new Gtk.ScrolledWindow({
        hexpand: true,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
    })
    scrollable.set_child(notificationList)
    stack.add_named(scrollable, "list")

    // == BOTTOM BAR ========================================================
    const countLabel = new Gtk.Label({
        css_classes: ["label--count"],
        halign: Gtk.Align.START,
        hexpand: true,
        label: "",
    })

    // DND button
    const dndBtn = new Gtk.Button({
        css_classes: ["btn", "btn--outlined"],
        tooltip_text: "Do not disturb",
        valign: Gtk.Align.CENTER,
    })
    dndBtn.set_child(new Gtk.Label({ label: "\udb80\udc9b" }))

    const updateDnd = () => {
        const active = notifd.dontDisturb
        dndBtn.css_classes = active
            ? ["btn", "btn--outlined", "btn--warn-active"]
            : ["btn", "btn--outlined"]
        dndBtn.tooltip_text = active ? "Do not disturb: on" : "Do not disturb: off"
    }
    updateDnd()
    dndBtn.connect("clicked", () => { notifd.dontDisturb = !notifd.dontDisturb; updateDnd() })

    // Clear button
    const clearBtnBox = new Gtk.Box({ spacing: 5, halign: Gtk.Align.CENTER })
    clearBtnBox.append(new Gtk.Image({ iconName: "edit-clear-all-symbolic" }))
    clearBtnBox.append(new Gtk.Label({ css_classes: ["text--sm"], label: "Clear" }))

    const clearBtn = new Gtk.Button({ css_classes: ["btn", "btn--outlined", "btn--danger"], valign: Gtk.Align.CENTER })
    clearBtn.set_child(clearBtnBox)
    clearBtn.connect("clicked", () => notifd.notifications.forEach(n => n.dismiss()))

    notifd.connect("notified", () => updateBottomBar())
    notifd.connect("resolved", () => updateBottomBar())

    const bottomBar = new Gtk.Box({
        css_classes: ["border--top"],
        spacing: 6,
        margin_top: 4,
    })
    bottomBar.append(countLabel)
    bottomBar.append(dndBtn)
    bottomBar.append(clearBtn)

    const updateBottomBar = () => {
        const count = widgetMap.size
        countLabel.label = count > 0 ? `${count} notification${count > 1 ? "s" : ""}` : ""
        clearBtn.visible = count > 0
    }

    // == ROOT ==============================================================
    const root = new Gtk.Box({
        css_classes: ["notification-feed"],
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 5,
        hexpand: true,
    })
    root.append(stack)
    root.append(bottomBar)

    updateStack()
    return root
}
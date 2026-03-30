import Gtk from "gi://Gtk?version=4.0"
import AstalNotifd from "gi://AstalNotifd"
import Notification from "./Notification"

export default function NotificationFeed(): Gtk.Widget {
    const notifd = AstalNotifd.get_default()

    const widgetMap = new Map<number, Gtk.Widget>()

    // == HEADER ============================================================
    const title = new Gtk.Label({
        label: "Notifications",
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
    })

    const dividerTop = new Gtk.Separator({
        css_classes: ["divider"],
    })

    // == EMPTY =============================================================
    const emptyBox = new Gtk.Box({
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 10,
        vexpand: true,
    })

    emptyBox.append(new Gtk.Image({
        iconName: "notifications-symbolic",
        pixelSize: 40,
        css_classes: ["icon--tertiary"],
    }))

    emptyBox.append(new Gtk.Label({
        label: "No notifications",
        css_classes: ["label--meta"],
    }))

    // == LIST ==============================================================
    const list = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 6,
    })

    const scroll = new Gtk.ScrolledWindow({
        vexpand: true,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
    })
    scroll.set_child(list)

    // == STACK =============================================================
    const stack = new Gtk.Stack({
        transitionType: Gtk.StackTransitionType.CROSSFADE,
        transitionDuration: 150,
        vexpand: true,
    })

    stack.add_named(emptyBox, "empty")
    stack.add_named(scroll, "list")

    // == DIVIDER BOTTOM ====================================================
    const dividerBottom = new Gtk.Separator({
        css_classes: ["divider"],
    })

    // == COUNT =============================================================
    const countLabel = new Gtk.Label({
        css_classes: ["label--count"],
        hexpand: true,
        halign: Gtk.Align.START,
    })

    // == DND ===============================================================
    const dndBtn = new Gtk.Button({
        css_classes: ["btn", "btn--elevated", "btn--round"],
    })

    const dndIcon = new Gtk.Image({
        icon_name: "notifications-disabled-symbolic",
    })
    dndBtn.set_child(dndIcon)

    const updateDnd = () => {
        const active = notifd.dontDisturb

        dndBtn.css_classes = active
            ? ["btn", "btn--elevated", "btn--round", "btn--warn-active"]
            : ["btn", "btn--elevated", "btn--round"]

        dndBtn.tooltip_text = active
            ? "Do not disturb: on"
            : "Do not disturb: off"
    }

    dndBtn.connect("clicked", () => {
        notifd.dontDisturb = !notifd.dontDisturb
        updateDnd()
    })

    // == CLEAR =============================================================
    const clearBtn = new Gtk.Button({
        css_classes: ["btn", "btn--outlined", "btn--danger"],
    })

    clearBtn.set_child(new Gtk.Image({
        icon_name: "edit-clear-all-symbolic",
    }))

    clearBtn.tooltip_text = "Clear notifications"

    clearBtn.connect("clicked", () => {
        notifd.notifications.forEach(n => n.dismiss())
    })

    // == BAR ===============================================================
    const bar = new Gtk.Box({
        spacing: 6,
    })

    bar.append(countLabel)
    bar.append(dndBtn)
    bar.append(clearBtn)

    // == UPDATE ============================================================
    const rebuild = () => {
        // clear list
        let child = list.get_first_child()
        while (child) {
            const next = child.get_next_sibling()
            child.unparent()
            child = next
        }

        widgetMap.clear()

        notifd.notifications.forEach(n => {
            const w = Notification({
                notification: n,
                onDismiss: () => n.dismiss(),
            })

            widgetMap.set(n.id, w)
            list.append(w)
        })

        const count = widgetMap.size

        stack.set_visible_child_name(count > 0 ? "list" : "empty")

        countLabel.label = count === 0
            ? ""
            : `${count} notification${count === 1 ? "" : "s"}`

        clearBtn.visible = count > 0

        updateDnd()
    }

    notifd.connect("notify::notifications", rebuild)
    notifd.connect("notify::dont-disturb", updateDnd)

    rebuild()

    // == ROOT ==============================================================
    const root = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
    })

    root.append(title)
    root.append(dividerTop)
    root.append(stack)
    root.append(dividerBottom)
    root.append(bar)

    return root
}
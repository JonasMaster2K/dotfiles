import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import GLib from "gi://GLib"
import AstalNotifd from "gi://AstalNotifd"
import Pango from "gi://Pango"

function guessMessageType(summary: string): string {
    const str = summary.toLowerCase()
    if (str.includes("reboot"))     return "system-reboot-symbolic"
    if (str.includes("recording"))  return "media-record-symbolic"
    if (str.includes("battery") || str.includes("power")) return "battery-symbolic"
    if (str.includes("screenshot")) return "camera-screen-symbolic"
    if (str.includes("welcome"))    return "face-smile-symbolic"
    if (str.includes("update"))     return "software-update-available-symbolic"
    if (str.includes("installed"))  return "emblem-downloads-symbolic"
    if (str.startsWith("file"))     return "folder-copy-symbolic"
    return "chat-symbolic"
}

function getFriendlyTime(time: number): string {
    const msgTime = GLib.DateTime.new_from_unix_local(time)
    const now = GLib.DateTime.new_now_local()
    if (msgTime.compare(now.add_seconds(-60)!) > 0) return "Now"
    if (msgTime.get_day_of_year() === now.get_day_of_year()) return msgTime.format("%H:%M")!
    if (msgTime.get_day_of_year() === now.get_day_of_year() - 1) return "Yesterday"
    return msgTime.format("%d.%m.%Y")!
}

function isIcon(icon?: string | null): boolean {
    if (!icon) return false
    return Gtk.IconTheme.get_for_display(Gdk.Display.get_default()!).has_icon(icon)
}

function fileExists(path: string): boolean {
    return GLib.file_test(path, GLib.FileTest.EXISTS)
}

function urgencyClass(n: AstalNotifd.Notification): string {
    if (n.urgency === AstalNotifd.Urgency.LOW)      return "notification--low"
    if (n.urgency === AstalNotifd.Urgency.CRITICAL) return "notification--critical"
    return "notification--normal"
}

interface NotificationProps {
    notification: AstalNotifd.Notification
    isPopup?: boolean
    onMinimize?: () => void
    onDismiss?: () => void
}

export default function Notification({
    notification: n,
    isPopup = false,
    onMinimize,
    onDismiss,
}: NotificationProps): Gtk.Widget {
    const urgency = urgencyClass(n)
    const destroyCommand  = () => onDismiss  ? onDismiss()  : n.dismiss()
    const minimizeCommand = () => onMinimize ? onMinimize() : undefined

    // == REVEALER ==========================================================
    const revealer = new Gtk.Revealer({
        transitionType: Gtk.RevealerTransitionType.SLIDE_LEFT,
        transitionDuration: 200,
        revealChild: false,
    })

    const card = new Gtk.Box({
        css_classes: ["notification__card", urgency],
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
    })
    revealer.set_child(card)

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10, () => { revealer.revealChild = true; return GLib.SOURCE_REMOVE })

    const destroyWithAnims = () => {
        if (!revealer.revealChild) return  // already animating out
        revealer.revealChild = false
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 220, () => {
            destroyCommand()
            revealer.unparent()
            return GLib.SOURCE_REMOVE
        })
    }
    const minimizeWithAnims = () => {
        revealer.revealChild = false
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => { minimizeCommand(); revealer.unparent(); return GLib.SOURCE_REMOVE })
    }

    if (isPopup) {
        const timeout = n.urgency === AstalNotifd.Urgency.CRITICAL ? 8000 : 3000
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, timeout, () => { minimizeWithAnims(); return GLib.SOURCE_REMOVE })
    }

    // == HEADER ============================================================
    const header = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 6 })

    // Icon
    let iconName = "chat-symbolic"
    if (n.image && fileExists(n.image))   iconName = n.image
    else if (isIcon(n.appIcon))           iconName = n.appIcon!
    else if (isIcon(n.desktopEntry))      iconName = n.desktopEntry!
    else                                  iconName = guessMessageType(n.summary)

    header.append(new Gtk.Image({ css_classes: ["notification__icon"], pixelSize: 16, icon_name: iconName }))

    // Summary
    header.append(new Gtk.Label({
        css_classes: ["label--subtitle"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        max_width_chars: 50,
        ellipsize: Pango.EllipsizeMode.END,
        label: n.summary,
    }))

    // Time
    const initTime = getFriendlyTime(n.time)
    const timeLabel = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.END, label: initTime })
    if (initTime === "Now") {
        const timerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 60000, () => { timeLabel.label = getFriendlyTime(n.time); return GLib.SOURCE_REMOVE })
        timeLabel.connect("destroy", () => GLib.source_remove(timerId))
    }
    header.append(timeLabel)

    // Controls
    const controls = new Gtk.Box({ halign: Gtk.Align.END, valign: Gtk.Align.CENTER, spacing: 2 })
    if (onMinimize) {
        const minBtn = new Gtk.Button({ css_classes: ["btn", "notification__btn--minimize"] })
        minBtn.set_child(new Gtk.Image({ iconName: "window-minimize-symbolic" }))
        minBtn.connect("clicked", minimizeWithAnims)
        controls.append(minBtn)
    }
    if (onDismiss) {
        const dismissBtn = new Gtk.Button({ css_classes: ["btn", "notification__btn--dismiss"] })
        dismissBtn.set_child(new Gtk.Image({ iconName: "window-close-symbolic" }))
        dismissBtn.connect("clicked", destroyWithAnims)
        controls.append(dismissBtn)
    }
    header.append(controls)

    // == BODY ==============================================================
    if (n.body) {
        const bodyRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 4 })

        const bodyBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true })

        const previewRevealer = new Gtk.Revealer({
            hexpand: true,
            transitionType: Gtk.RevealerTransitionType.SLIDE_DOWN,
            transitionDuration: 75,
            revealChild: true,
        })
        const previewLabel = new Gtk.Label({
            css_classes: ["label--meta"],
            max_width_chars: 70,
            ellipsize: Pango.EllipsizeMode.END,
            label: n.body.split("\n")[0] || "",
            halign: Gtk.Align.START,
        })
        previewRevealer.set_child(previewLabel)
        bodyBox.append(previewRevealer)

        // Only show expand button if body has multiple lines or is long
        const hasMoreContent = n.body.includes("\n") || n.body.length > 80

        if (hasMoreContent) {
            const fullRevealer = new Gtk.Revealer({
                hexpand: true,
                transitionType: Gtk.RevealerTransitionType.SLIDE_DOWN,
                transitionDuration: 75,
                revealChild: false,
            })
            const fullLabel = new Gtk.Label({
                css_classes: ["label--meta"],
                wrap: true,
                max_width_chars: 70,
                label: n.body,
                halign: Gtk.Align.START,
            })
            fullRevealer.set_child(fullLabel)
            bodyBox.append(fullRevealer)

            let expanded = false
            const expandBtn = new Gtk.Button({ css_classes: ["btn"] })
            const expandIcon = new Gtk.Image({ iconName: "pan-down-symbolic" })
            expandBtn.set_child(expandIcon)
            expandBtn.connect("clicked", () => {
                expanded = !expanded
                previewRevealer.revealChild = !expanded
                fullRevealer.revealChild = expanded
                expandIcon.iconName = expanded ? "pan-up-symbolic" : "pan-down-symbolic"
            })

            bodyRow.append(bodyBox)
            bodyRow.append(expandBtn)
        } else {
            bodyRow.append(bodyBox)
        }

        card.append(bodyRow)
    }

    // == ACTIONS ===========================================================
    if (n.actions && n.actions.length > 0) {
        const actionsBox = new Gtk.Box({ spacing: 4, halign: Gtk.Align.CENTER })
        n.actions.forEach((action: AstalNotifd.Action) => {
            const btn = new Gtk.Button({
                css_classes: ["btn", "btn--outlined"],
                label: action.label,
            })
            btn.connect("clicked", () => {
                n.invoke(action.id)
                destroyWithAnims()
            })
            actionsBox.append(btn)
        })
        card.append(actionsBox)
    }

    // correct order: header always first
    card.prepend(header)

    return revealer
}
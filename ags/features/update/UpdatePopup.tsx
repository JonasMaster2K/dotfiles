import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

export interface UpdatePopupRefs {
    popover: Gtk.Popover
    rebuildList: (items: string[]) => void
}

const updateList = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 2 })

const scrollable = new Gtk.ScrolledWindow({
    hscrollbar_policy: Gtk.PolicyType.NEVER,
    vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
    max_content_height: 300,
    propagate_natural_height: true,
})
scrollable.set_child(updateList)

// HEADER
const headerLabel = new Gtk.Label({
    css_classes: ["label--section"],
    halign: Gtk.Align.START,
    label: "Available Updates",
})

// UPDATE ALL BUTTON
const updateAllBox = new Gtk.Box({ spacing: 6, halign: Gtk.Align.CENTER })
updateAllBox.append(new Gtk.Image({ icon_name: "software-update-available-symbolic", pixel_size: 14 }))
updateAllBox.append(new Gtk.Label({ css_classes: ["text--sm"], label: "Update all" }))

const updateAllBtn = new Gtk.Button({
    css_classes: ["btn", "btn--accent"],
    hexpand: true,
})
updateAllBtn.set_child(updateAllBox)
updateAllBtn.connect("clicked", () => GLib.spawn_command_line_async("kitty -- paru -Syu"))

// CONTENT
const popoverBox = new Gtk.Box({
    css_classes: ["popover--panel"],
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 8,
    width_request: 260,
})
popoverBox.append(headerLabel)
popoverBox.append(scrollable)
popoverBox.append(new Gtk.Separator({ css_classes: ["divider"] }))
popoverBox.append(updateAllBtn)

const popover = new Gtk.Popover({
    css_classes: ["update-popover"],
    has_arrow: false,
    autohide: true,
})
popover.set_child(popoverBox)
popover.set_offset(0, 10)

const rebuildList = (items: string[]) => {
    let child = updateList.get_first_child()
    while (child) { updateList.remove(child); child = updateList.get_first_child() }

    items.forEach(pkg => updateList.append(new Gtk.Label({
        css_classes: ["label--mono-sm"],
        label: pkg,
        halign: Gtk.Align.START,
        ellipsize: 3,
        max_width_chars: 35,
    })))
}

export default function UpdatePopup(): UpdatePopupRefs {
    return { popover, rebuildList }
}
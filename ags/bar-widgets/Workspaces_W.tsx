import AstalHyprland from "gi://AstalHyprland?version=0.1"
import AstalApps from "gi://AstalApps?version=0.1"
import { Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"

const manager  = new AstalApps.Apps()
const hyprland = AstalHyprland.get_default()

function getIconName(appId: string): string {
    const id = appId.toLowerCase()
    const apps = manager.get_list()
    return (
        apps.find((a: any) => a.wm_class?.toLowerCase() === id)?.iconName ??
        apps.find((a: any) => a.entry?.toLowerCase().replace(".desktop", "") === id)?.iconName ??
        apps.find((a: any) => a.name?.toLowerCase() === id)?.iconName ??
        apps.find((a: any) => a.iconName?.toLowerCase() === id)?.iconName ??
        apps.find((a: any) => a.wm_class?.toLowerCase().includes(id) || id.includes(a.wm_class?.toLowerCase()))?.iconName ??
        apps.find((a: any) => a.iconName?.toLowerCase().includes(id) || id.includes(a.iconName?.toLowerCase()))?.iconName ??
        apps.find((a: any) => a.name?.toLowerCase().includes(id) || id.includes(a.name?.toLowerCase()))?.iconName ??
        "application-x-executable"
    )
}

// ============================================================
// WORKSPACE BUTTON
// ============================================================
function WorkspaceButton(ws: any): Gtk.Widget {
    const btn = new Gtk.Button({ valign: Gtk.Align.CENTER })

    const innerBox = new Gtk.Box({ spacing: 5 })
    innerBox.append(new Gtk.Label({ css_classes: ["workspace__label"], label: ws.id >= 0 ? ws.id.toString() : `S${ws.id + 99}` }))

    const iconBox = new Gtk.Box({ spacing: 2 })
    innerBox.append(iconBox)
    btn.set_child(innerBox)

    const updateClasses = () => {
        const active = hyprland.focusedWorkspace?.id === ws.id
        btn.css_classes = active
            ? ["statusbar-widget", "workspace__btn", "workspace__btn--active"]
            : ["statusbar-widget", "workspace__btn"]
    }

    if (ws.id < 0) {
        hyprland.connect("event", (_: any, event: string, data: string) => {
            if (event === "activespecial") {
                const openName = data.split(",")[0] // "special:scratchpad" oder ""
                const isOpen = openName === ws.name
                btn.css_classes = isOpen
                    ? ["statusbar-widget", "workspace__btn", "workspace__btn--active"]
                    : ["statusbar-widget", "workspace__btn"]
            }
        })
    }
    updateClasses()
    hyprland.connect("notify::focused-workspace", updateClasses)

    if (ws.monitor) {
        const updateIcons = () => {
            let child = iconBox.get_first_child()
            while (child) { iconBox.remove(child); child = iconBox.get_first_child() }
            ws.clients.forEach((win: any) => {
                iconBox.append(new Gtk.Image({
                    css_classes: ["workspace__app-icon"],
                    icon_name: getIconName(win.class),
                    pixel_size: 14,
                }))
            })
        }
        updateIcons()
        ws.connect("notify::clients", updateIcons)
        btn.connect("clicked", () => ws.focus())
    }

    return btn
}

// ============================================================
// WORKSPACES WIDGET
// ============================================================
export default function WorkspacesWidget(gdkMonitor?: Gdk.Monitor, isPrimary = true): Gtk.Widget {
    const monitorModel = gdkMonitor?.model ?? ""

    const baseIds   = isPrimary ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10]

    const box = new Gtk.Box({
        css_classes: ["workspaces"],
        valign: Gtk.Align.CENTER,
        spacing: 2,
    })

    const updateWorkspaces = () => {
        const filtered = hyprland.workspaces
            .filter((w: any) => w.monitor?.model === monitorModel)
            .sort((a: any, b: any) => a.id - b.id)

        const fixed = baseIds.map((id: number) =>
            filtered.find((w: any) => w.id === id) ?? { id, monitor: null, clients: [] }
        )
        const extra = filtered.filter((w: any) => !baseIds.includes(w.id))
        const all   = [...fixed, ...extra]

        let child = box.get_first_child()
        while (child) { box.remove(child); child = box.get_first_child() }
        all.forEach((ws: any) => box.append(WorkspaceButton(ws)))
    }

    updateWorkspaces()
    hyprland.connect("notify::workspaces", updateWorkspaces)

    return box
}
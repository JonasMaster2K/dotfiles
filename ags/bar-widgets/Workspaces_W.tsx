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
        apps.find((a: AstalApps.Application) => a.wm_class?.toLowerCase() === id)?.iconName ??
        apps.find((a: AstalApps.Application) => a.entry?.toLowerCase().replace(".desktop", "") === id)?.iconName ??
        apps.find((a: AstalApps.Application) => a.name?.toLowerCase() === id)?.iconName ??
        apps.find((a: AstalApps.Application) => a.iconName?.toLowerCase() === id)?.iconName ??
        apps.find((a: AstalApps.Application) => a.wm_class?.toLowerCase().includes(id) || id.includes(a.wm_class?.toLowerCase()))?.iconName ??
        apps.find((a: AstalApps.Application) => a.iconName?.toLowerCase().includes(id) || id.includes(a.iconName?.toLowerCase()))?.iconName ??
        apps.find((a: AstalApps.Application) => a.name?.toLowerCase().includes(id) || id.includes(a.name?.toLowerCase()))?.iconName ??
        "application-x-executable"
    )
}

// Discriminated Union
type WS =
    | AstalHyprland.Workspace
    | {
        id: number
        monitor: null
        clients: AstalHyprland.Client[]
        isPlaceholder: true
    }

// ============================================================
// WORKSPACE BUTTON
// ============================================================

function WorkspaceButton(ws: WS): Gtk.Widget {
    const isReal = (ws: WS): ws is AstalHyprland.Workspace =>
        !("isPlaceholder" in ws)

    const btn = new Gtk.Button({ valign: Gtk.Align.CENTER })

    const innerBox = new Gtk.Box({ spacing: 5 })
    innerBox.append(new Gtk.Label({
        css_classes: ["workspace__label"],
        valign: Gtk.Align.CENTER,
        label: ws.id >= 0 ? ws.id.toString() : `S${ws.id + 99}`,
    }))

    const iconBox = new Gtk.Box({ spacing: 2 })
    innerBox.append(iconBox)
    btn.set_child(innerBox)

    const updateClasses = () => {
        const active = hyprland.focusedWorkspace?.id === ws.id
        btn.css_classes = active
            ? ["statusbar-widget", "workspace__btn", "workspace__btn--active"]
            : ["statusbar-widget", "workspace__btn"]
    }

    if (ws.id < 0 && isReal(ws)) {
        hyprland.connect("event", (_: AstalHyprland.Hyprland, event: string, data: string) => {
            if (event === "activespecial") {
                const openName = data.split(",")[0]
                const isOpen = openName === ws.name
                btn.css_classes = isOpen
                    ? ["statusbar-widget", "workspace__btn", "workspace__btn--active"]
                    : ["statusbar-widget", "workspace__btn"]
            }
        })
    }

    updateClasses()
    hyprland.connect("notify::focused-workspace", updateClasses)

    if (ws.monitor && isReal(ws)) {
        const updateIcons = () => {
            let child = iconBox.get_first_child()
            while (child) {
                iconBox.remove(child)
                child = iconBox.get_first_child()
            }

            ws.clients.forEach((win: AstalHyprland.Client) => {
                iconBox.append(new Gtk.Image({
                    css_classes: ["workspace__app-icon"],
                    icon_name: getIconName(win.class),
                    pixel_size: 14,
                }))
            })
        }

        updateIcons()
        ws.connect("notify::clients", updateIcons)
    }

    btn.connect("clicked", () => {
        if (isReal(ws)) {
            ws.focus()
        } else {
            hyprland.dispatch("workspace", String(ws.id))
        }
    })

    return btn
}

// ============================================================
// WORKSPACES WIDGET
// ============================================================

export default function WorkspacesWidget(gdkMonitor?: Gdk.Monitor, isPrimary = true): Gtk.Widget {
    const monitorModel = gdkMonitor?.model ?? ""

    const baseIds = isPrimary ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10]

    const box = new Gtk.Box({
        css_classes: ["workspaces"],
        valign: Gtk.Align.CENTER,
        spacing: 2,
    })

    const updateWorkspaces = () => {
        const filtered = hyprland.workspaces
            .filter((w: AstalHyprland.Workspace) => w.monitor?.model === monitorModel)
            .sort((a, b) => a.id - b.id)

        const fixed: WS[] = baseIds.map((id: number) =>
            filtered.find(w => w.id === id) ?? {
                id,
                monitor: null,
                clients: [],
                isPlaceholder: true,
            }
        )

        const extra: WS[] = filtered.filter(w => !baseIds.includes(w.id))

        const all: WS[] = [...fixed, ...extra]

        let child = box.get_first_child()
        while (child) {
            box.remove(child)
            child = box.get_first_child()
        }

        all.forEach(ws => box.append(WorkspaceButton(ws)))
    }

    updateWorkspaces()
    hyprland.connect("notify::workspaces", updateWorkspaces)

    return box
}
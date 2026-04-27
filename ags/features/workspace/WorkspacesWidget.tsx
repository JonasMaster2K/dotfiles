import AstalHyprland from "gi://AstalHyprland?version=0.1"
import { Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"
import getIconName from "../../utils/getIconName"
import BarButton from "../../components/BarButton"

const hyprland = AstalHyprland.get_default()

type Workspace =
    | AstalHyprland.Workspace
    | { id: number; monitor: null; clients: AstalHyprland.Client[]; isPlaceholder: true }

function WorkspaceButton(ws: Workspace): Gtk.Widget {
    const isWorkspace = (ws: Workspace): ws is AstalHyprland.Workspace =>
        !("isPlaceholder" in ws)

    const btn = new BarButton({ iconName: "" })

    const label = new Gtk.Label({
        css_classes: ["workspace__label"],
        label: ws.id >= 0 ? ws.id.toString() : `S${ws.id + 99}`,
        halign: Gtk.Align.CENTER,
        xalign: 0.5,
    })
    btn.content.append(label)

    const iconBox = new Gtk.Box({ spacing: 2, visible: false })
    btn.content.append(iconBox)

    if (ws.id < 0 && isWorkspace(ws)) {
        hyprland.connect("event", (_: AstalHyprland.Hyprland, event: string, data: string) => {
            if (event === "activespecial") {
                const isOpen = data.split(",")[0] === ws.name
                btn.css_classes = isOpen
                    ? ["bar__btn", "workspace__btn", "workspace__btn--active"]
                    : ["bar__btn", "workspace__btn"]
            }
        })
    }

    const updateClasses = () => {
        const active = hyprland.focusedWorkspace?.id === ws.id
        btn.css_classes = active
            ? ["bar__btn", "workspace__btn", "workspace__btn--active"]
            : ["bar__btn", "workspace__btn"]
    }
    updateClasses()
    hyprland.connect("notify::focused-workspace", updateClasses)

    const updateIcons = () => {
        let child = iconBox.get_first_child()
        while (child) { iconBox.remove(child); child = iconBox.get_first_child() }
        ws.clients.forEach((win: AstalHyprland.Client) => {
            iconBox.append(new Gtk.Image({
                css_classes: ["workspace__app-icon"],
                icon_name: getIconName(win.class),
                pixel_size: 20,
                valign: Gtk.Align.CENTER,
            }))
        })
        iconBox.visible = ws.clients.length > 0
    }

    if (isWorkspace(ws)) {
        updateIcons()
        ws.connect("notify::clients", updateIcons)
    }

    btn.connect("clicked", () => {
        if (isWorkspace(ws)) ws.focus()
        else hyprland.dispatch("workspace", String(ws.id))
    })

    return btn
}

export default function WorkspacesWidget(gdkMonitor?: Gdk.Monitor, isPrimary = true): Gtk.Widget {
    const monitorModel = gdkMonitor?.model ?? ""
    const baseIds = isPrimary ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10]

    const box = new Gtk.Box({
        css_classes: ["bar__workspaces"],
        valign: Gtk.Align.FILL,
    })

    const updateWorkspaces = () => {
        const monitorName = hyprland.monitors.find(m => m.model === monitorModel)?.name ?? ""
        const filtered = hyprland.workspaces
            .filter((w: AstalHyprland.Workspace) => w.monitor?.name === monitorName)
            .sort((a, b) => a.id - b.id)

        const fixed: Workspace[] = baseIds.map(id =>
            filtered.find(w => w.id === id) ?? { id, monitor: null, clients: [], isPlaceholder: true }
        )
        const extra = filtered.filter(w => !baseIds.includes(w.id))
        const all   = [...fixed, ...extra]

        let child = box.get_first_child()
        while (child) { box.remove(child); child = box.get_first_child() }
        all.forEach(ws => box.append(WorkspaceButton(ws)))
    }

    updateWorkspaces()
    hyprland.connect("notify::monitors",   updateWorkspaces)
    hyprland.connect("notify::workspaces", updateWorkspaces)

    return box
}
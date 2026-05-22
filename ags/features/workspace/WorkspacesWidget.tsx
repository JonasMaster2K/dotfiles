/**
 * @file WorkspacesWidget.ts
 * @description Ein AGS (Aylur's GTK Shell) Widget für GTK4, das die Hyprland-Workspaces in einer Statusleiste visualisiert.
 * 
 * Kernfeatures:
 * - **Multi-Monitor-Unterstützung:** Filtert und zeigt Workspaces dynamisch basierend auf dem aktuellen Monitor-Modell.
 * - **Persistente Basis-Workspaces:** Hält die IDs 1-5 als Platzhalter permanent sichtbar, auch wenn sie leer sind. Weitere aktive Workspaces werden dynamisch angehängt.
 * - **Dynamische App-Indikatoren:** Zeigt geöffnete Fenster innerhalb der Workspaces als App-Icons an.
 *   - Bei 1-2 Fenstern werden große Einzel-Icons gerendert.
 *   - Ab 3 Fenstern wechselt das Layout in ein kompaktes 2x2-Grid.
 *   - Übersteigt die Fensteranzahl 4 Clients, wird das vierte Icon durch ein `+` (Symbolic Icon) ersetzt, um Überlauf zu verhindern.
 * - **Spezial-Workspaces:** Unterstützt Hyprland-Scratchpads (negative IDs) mit Ereignis-Überwachung für den Sichtbarkeitsstatus.
 * 
 * @dependencies AstalHyprland, ags/gtk4, ags/process
 */

import AstalHyprland from "gi://AstalHyprland?version=0.1"
import { Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"
import { execAsync } from "ags/process"
import getIconName from "../../utils/getIconName"
import BarButton from "../../components/BarButton"

const hyprland = AstalHyprland.get_default()

type Workspace =
    | AstalHyprland.Workspace
    | { id: number; monitor: null; clients: AstalHyprland.Client[]; isPlaceholder: true }

const isWorkspace = (ws: Workspace): ws is AstalHyprland.Workspace => !("isPlaceholder" in ws)

const MAX_GRID_WIDTH_HEIGHT = 2

/**
 * Erstellt den interaktiven Button für einen einzelnen Workspace.
 * Verwaltet den internen Fokus-Status, Scratchpad-Events und das dynamische Icon-Grid.
 */
function WorkspaceButton(ws: Workspace): Gtk.Widget {
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

    const setButtonClass = (isActive: boolean) => {
        btn.css_classes = isActive
            ? ["bar__btn", "workspace__btn", "workspace__btn--active"]
            : ["bar__btn", "workspace__btn"]
    }

    if (ws.id < 0 && isWorkspace(ws)) {
        hyprland.connect("event", (_, event: string, data: string) => {
            if (event === "activespecial") {
                const isOpen = data.split(",")[0] === ws.name
                setButtonClass(isOpen)
            }
        })
    }

    const updateClasses = () => setButtonClass(hyprland.focusedWorkspace?.id === ws.id)
    updateClasses()
    hyprland.connect("notify::focused-workspace", updateClasses)

    const updateIcons = () => {
        while (iconBox.get_first_child()) {
            iconBox.remove(iconBox.get_first_child()!)
        }

        const grid = new Gtk.Grid({
            valign: Gtk.Align.CENTER,
            column_spacing: 2,
            row_spacing: 2,
        })
        iconBox.append(grid)

        let icon_count = 0
        const totalClients = ws.clients.length
        const showPlusIcon = totalClients > 4

        for (const win of ws.clients) {
            if (showPlusIcon && icon_count === 3) {
                grid.attach(
                    new Gtk.Image({
                        css_classes: ["workspace__app-icon", "workspace__app-icon--more"],
                        icon_name: "list-add-symbolic",
                        pixel_size: 11,
                        valign: Gtk.Align.CENTER,
                    }),
                    icon_count % MAX_GRID_WIDTH_HEIGHT,
                    Math.floor(icon_count / MAX_GRID_WIDTH_HEIGHT),
                    1,
                    1
                )
                break
            }

            grid.attach(
                new Gtk.Image({
                    css_classes: ["workspace__app-icon"],
                    icon_name: getIconName(win.class),
                    pixel_size: totalClients > 2 ? 11 : 28,
                    valign: Gtk.Align.CENTER,
                }),
                icon_count % MAX_GRID_WIDTH_HEIGHT,
                Math.floor(icon_count / MAX_GRID_WIDTH_HEIGHT),
                1,
                1
            )
            icon_count++
        }

        iconBox.visible = totalClients > 0
    }

    if (isWorkspace(ws)) {
        updateIcons()
        ws.connect("notify::clients", updateIcons)
    }

    btn.connect("clicked", () => {
        execAsync(['hyprctl', 'dispatch', `hl.dsp.focus({ workspace = ${ws.id} })`])
            .catch(err => console.error("Hyprland dispatch error:", err))
    })

    return btn
}

/**
 * Der exportierte Haupt-Widget-Container (Workspace-Bar).
 * Reagiert auf Monitor- und Workspace-Änderungen von Hyprland und baut die Liste periodisch neu auf.
 * 
 * @param gdkMonitor Der Gdk-Monitor, auf dem das Widget platziert wird.
 */
export default function WorkspacesWidget(gdkMonitor?: Gdk.Monitor): Gtk.Widget {
    const monitorModel = gdkMonitor?.model ?? ""
    const baseIds = [1, 2, 3, 4, 5]

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
        
        while (box.get_first_child()) {
            box.remove(box.get_first_child()!)
        }

        [...fixed, ...extra].forEach(ws => {box.append(WorkspaceButton(ws))})
    }

    updateWorkspaces()
    hyprland.connect("notify::monitors", updateWorkspaces)
    hyprland.connect("notify::workspaces", updateWorkspaces)

    return box
}
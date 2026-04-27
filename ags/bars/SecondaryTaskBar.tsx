import { Astal, Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"

import WorkspacesWidget from "../features/workspace/WorkspacesWidget"
import ClockWidget      from "../features/clock/ClockWidget"
import SysInfoWidget    from "../features/systeminfo/SystemInfoWidget"
import HomeMenuWidget   from "../features/homemenu/HomeMenuWidget"

const append = (box: Gtk.Box, widget: Gtk.Widget | null) => {
    if (widget !== null) box.append(widget)
}

export default function SecondaryBar(monitor: Gdk.Monitor): Astal.Window {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const workspaces = WorkspacesWidget(monitor, false)
    const clock      = ClockWidget()
    const sysInfo    = SysInfoWidget()
    const homeMenu   = HomeMenuWidget()

    const left = new Gtk.Box({ halign: Gtk.Align.START, hexpand: true })
    append(left, workspaces)

    const center = new Gtk.Box({ halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
    append(center, clock)

    const right = new Gtk.Box({ halign: Gtk.Align.END, hexpand: true, spacing: 4 })
    append(right, sysInfo)
    right.append(new Gtk.Separator())
    append(right, homeMenu)

    const outerBox = new Gtk.Box({ hexpand: true })
    outerBox.append(left)
    outerBox.append(right)

    const overlay = new Gtk.Overlay({ hexpand: true })
    overlay.set_child(outerBox)
    overlay.add_overlay(center)

    const win = new Astal.Window({
        visible: true,
        gdkmonitor: monitor,
        anchor: TOP | LEFT | RIGHT,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
        height_request: 45,
        css_classes: ["taskbar"],
        layer: Astal.Layer.TOP,
    })
    win.set_child(overlay)

    monitor.connect("invalidate", () => win.destroy())

    return win
}
import { Astal, Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"
import GLib from "gi://GLib?version=2.0"

import WorkspacesWidget   from "../features/workspace/WorkspacesWidget"
import MediaPlayerWidget  from "../features/mediaplayer/MediaPlayerWidget"
import ClockWidget        from "../features/clock/ClockWidget"
import UpdateWidget       from "../features/update/UpdateWidget"
import SysInfoWidget      from "../features/systeminfo/SystemInfoWidget"
import ColorPickerWidget  from "../features/colorpicker/ColorPickerWidget"
import ScreenshotWidget   from "../features/screenshot/ScreenshotWidget"
import NotificationWidget from "../features/notification/NotificationWidget"
import AudioWidget        from "../features/audio/AudioWidget"
import NetworkWidget      from "../features/network/NetworkWidget"
import BluetoothWidget    from "../features/bluetooth/BluetoothWidget"
import BatteryWidget      from "../features/battery/BatteryWidget"
import PowerWidget        from "../features/power/PowerMenuWidget"
import HomeMenuWidget     from "../features/homemenu/HomeMenuWidget"
import DarkModeToggle     from "../features/theme/ThemeToggleWidget"
import PomodoroWidget     from "../features/pomodoro/PomodoroWidget"
import SystemTrayWidget   from "../features/tray/TrayWidget"

const BARHEIGHT: number = 45

const append = (box: Gtk.Box, widget: Gtk.Widget | null) => {
    if (widget !== null) box.append(widget)
}

export default function PrimaryBar(monitor: Gdk.Monitor): Astal.Window {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    // --- Widgets ---
    const workspaces   = WorkspacesWidget(monitor, true)
    const mediaPlayer  = MediaPlayerWidget(BARHEIGHT)
    const clock        = ClockWidget()
    const darkMode     = DarkModeToggle()
    const pomodoro     = PomodoroWidget()
    const updates      = UpdateWidget()
    const sysInfo      = SysInfoWidget()
    const colorPicker  = ColorPickerWidget()
    const screenshot   = ScreenshotWidget()
    const notifications = NotificationWidget()
    const audio        = AudioWidget()
    const network      = NetworkWidget()
    const bluetooth    = BluetoothWidget()
    const battery      = BatteryWidget()
    const power        = PowerWidget()
    const homeMenu     = HomeMenuWidget()
    const systemTray   = SystemTrayWidget()

    // --- Left ---
    const left = new Gtk.Box({ halign: Gtk.Align.START, hexpand: true })
    append(left, workspaces)
    left.append(new Gtk.Separator())
    append(left, mediaPlayer)
    left.append(new Gtk.Separator())
    left.append(new Gtk.Box({width_request: 4}))
    append(left, pomodoro)

    // --- Center ---
    const center = new Gtk.Box({ halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
    append(center, clock)

    // --- Right ---
    const right = new Gtk.Box({ halign: Gtk.Align.END, hexpand: true })
    //append(right, updates)
    //append(right, sysInfo)
    //right.append(new Gtk.Separator())
    //append(right, colorPicker)
    append(right, screenshot)
    //append(right, darkMode)
    //append(right, notifications)
    append(right, audio)
    append(right, network)
    append(right, bluetooth)
    append(right, battery)
    //append(right, systemTray)
    //right.append(new Gtk.Separator())
    //append(right, power)
    //append(right, homeMenu)

    // --- Layout ---
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
        vexpand: true,
        css_classes: ["taskbar"],
        layer: Astal.Layer.TOP,
    })
    win.set_child(overlay)

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
        print("height:", win.get_allocated_height())
        return GLib.SOURCE_REMOVE
    })

    return win
}
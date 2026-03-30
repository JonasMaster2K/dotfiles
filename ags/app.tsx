import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"

import WorkspacesWidget    from "./bar-widgets/Workspaces_W"
import MediaPlayerWidget   from "./bar-widgets/MediaPlayer_W"
import ClockWidget         from "./bar-widgets/Clock_W"
import UpdateWidget        from "./bar-widgets/Update_W"
import SysInfoWidget       from "./bar-widgets/SysInfo_W"
import ColorPickerWidget   from "./bar-widgets/ColorPicker_W"
import ScreenshotWidget    from "./bar-widgets/Screenshot_W"
import NotificationWidget  from "./bar-widgets/Notification_W"
import AudioWidget         from "./bar-widgets/Audio_W"
import NetworkWidget       from "./bar-widgets/Network_W"
import BluetoothWidget     from "./bar-widgets/Bluetooth_W"
import BatteryWidget       from "./bar-widgets/Battery_W"
import PowerWidget         from "./bar-widgets/Power_W"
import HomeMenuWidget      from "./bar-widgets/HomeMenu_W"
import DarkModeToggle      from "./bar-widgets/DarkLightModeToggle_W"
import PomodoroWidget      from "./bar-widgets/Pomodoro_W"

import NotificationPopupFeed from "./components/NotificationPopupFeed"

const appendIfNotNull = (box: Gtk.Box, widget: Gtk.Widget | null) => {
    if (widget !== null) box.append(widget)
}

// ============================================================
// PRIMARY BAR (main monitor)
// ============================================================
function createPrimaryBar(monitor: Gdk.Monitor): Astal.Window {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const workspaces        = WorkspacesWidget(monitor, true)
    const mediaPlayer       = MediaPlayerWidget()
    const clock             = ClockWidget()
    const darkModeToggle    = DarkModeToggle()
    const pomodoro          = PomodoroWidget()
    const updates           = UpdateWidget()
    const sysInfo           = SysInfoWidget()
    const colorPicker       = ColorPickerWidget()
    const screenshot        = ScreenshotWidget()
    const notifications     = NotificationWidget()
    const audio             = AudioWidget()
    const network           = NetworkWidget()
    const bluetooth         = BluetoothWidget()
    const battery           = BatteryWidget()
    const power             = PowerWidget()
    const homeMenu          = HomeMenuWidget()

    const leftModule = new Gtk.Box({ halign: Gtk.Align.START, hexpand: true })
    appendIfNotNull(leftModule, workspaces)
    leftModule.append(new Gtk.Separator())
    appendIfNotNull(leftModule, mediaPlayer)
    leftModule.append(new Gtk.Separator())
    appendIfNotNull(leftModule, pomodoro)

    const centerBox = new Gtk.Box({ halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
    appendIfNotNull(centerBox, clock)

    const rightModule = new Gtk.Box({ halign: Gtk.Align.END, hexpand: true, spacing: 4 })
    appendIfNotNull(rightModule, updates)
    appendIfNotNull(rightModule, sysInfo)
    rightModule.append(new Gtk.Separator())
    appendIfNotNull(rightModule, colorPicker)
    appendIfNotNull(rightModule, screenshot)
    appendIfNotNull(rightModule, darkModeToggle)
    appendIfNotNull(rightModule, notifications)
    appendIfNotNull(rightModule, audio)
    appendIfNotNull(rightModule, network)
    appendIfNotNull(rightModule, bluetooth)
    appendIfNotNull(rightModule, battery)
    rightModule.append(new Gtk.Separator())
    appendIfNotNull(rightModule, power)
    appendIfNotNull(rightModule, homeMenu)

    const outerBox = new Gtk.Box({ hexpand: true })
    outerBox.append(leftModule)
    outerBox.append(rightModule)

    const overlay = new Gtk.Overlay({ hexpand: true })
    overlay.set_child(outerBox)
    overlay.add_overlay(centerBox)

    const win = new Astal.Window({
        visible: true,
        gdkmonitor: monitor,
        anchor: TOP | LEFT | RIGHT,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
        height_request: 40,
        css_classes: ["taskBar"],
        layer: Astal.Layer.TOP,
    })
    win.set_child(overlay)
    return win
}

// ============================================================
// SECONDARY BAR (extra monitors)
// ============================================================
function createSecondaryBar(monitor: Gdk.Monitor): Astal.Window {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const workspaces = WorkspacesWidget(monitor, false)
    const clock      = ClockWidget()
    const sysInfo    = SysInfoWidget()
    const homeMenu   = HomeMenuWidget()

    const leftModule = new Gtk.Box({ halign: Gtk.Align.START, hexpand: true })
    appendIfNotNull(leftModule, workspaces)

    const centerBox = new Gtk.Box({ halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
    appendIfNotNull(centerBox, clock)

    const rightModule = new Gtk.Box({ halign: Gtk.Align.END, hexpand: true, spacing: 4 })
    appendIfNotNull(rightModule, sysInfo)
    rightModule.append(new Gtk.Separator())
    appendIfNotNull(rightModule, homeMenu)

    const outerBox = new Gtk.Box({ hexpand: true })
    outerBox.append(leftModule)
    outerBox.append(rightModule)

    const overlay = new Gtk.Overlay({ hexpand: true })
    overlay.set_child(outerBox)
    overlay.add_overlay(centerBox)

    const win = new Astal.Window({
        visible: true,
        gdkmonitor: monitor,
        anchor: TOP | LEFT | RIGHT,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
        height_request: 40,
        css_classes: ["taskBar"],
        layer: Astal.Layer.TOP,
    })
    win.set_child(overlay)

    monitor.connect("invalidate", () => win.destroy())

    return win
}

// ============================================================
// APP
// ============================================================
app.start({
    css: "./style/themes/Dark-Mode/style.scss",
    main() {
        NotificationPopupFeed()

        const monitors = Gdk.Display.get_default()!.get_monitors()

        // Bestehende Monitore
        const primary = monitors.get_item(0) as Gdk.Monitor
        const primaryWin = createPrimaryBar(primary)

        for (let i = 1; i < monitors.get_n_items(); i++) {
            createSecondaryBar(monitors.get_item(i) as Gdk.Monitor)
        }

        // Hotplug
        monitors.connect("items-changed", (_: any, pos: number, _removed: number, added: number) => {
            for (let i = pos; i < pos + added; i++) {
                createSecondaryBar(monitors.get_item(i) as Gdk.Monitor)
            }
        })

        return primaryWin
    },
})
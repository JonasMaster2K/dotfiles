import { Gtk } from "ags/gtk4"
import BarButton from "../../components/BarButton"
import PomodoroTimer from "../../services/PomodoroTimer"
import PomodoroPopup from "./PomodoroPopup"
import formatTime from "../../utils/formatTime"

const timer = new PomodoroTimer()

export default function PomodoroWidget(): Gtk.Widget {
    const btn = new BarButton({ iconName: timer.icon_name })

    const popup = PomodoroPopup(() => timer)
    popup.set_parent(btn)

    //===============================
    //---------- STRUCTURE ----------
    //===============================
    // Das Overlay umschließt unsere neue Inhalts-Box
    const overlay = new Gtk.Overlay({
        hexpand: true,
        visible: false,
    })
    btn.content.append(overlay)

    // Die Box nimmt das originale Icon und das Zeit-Label auf
    const contentBox = new Gtk.Box({
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    })
    overlay.set_child(contentBox)

    // Das originale Icon (Brain etc.) wird in die Box geschoben
    if (btn.icon) {
        contentBox.append(btn.icon)
    }

    // Das Zeit-Label wird ebenfalls in die Box geschoben
    const label = new Gtk.Label({
        label: formatTime(timer.remaining),
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        css_classes: ["pomodoro-label"]
    })
    contentBox.append(label)

    // Das Pause-Icon legt sich als echtes Overlay über die gesamte Box
    const pause_icon = new Gtk.Image({
        icon_name: "media-playback-pause-symbolic",
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        pixel_size: 24,
        css_classes: ["pomodoro-pause-label"]
    })
    overlay.add_overlay(pause_icon)

    //===============================
    //-------- FUNCTIONALITY --------
    //===============================
    timer.connect("notify::icon-name", () => {
        // "pomodoro-widget" bleibt als eindeutige Kennung immer erhalten
        btn.cssClasses = ["bar__btn", "pomodoro-widget", `phase--${timer.phase}`]
        
        if (btn.icon) btn.icon.set_from_icon_name(timer.icon_name)
        overlay.visible = (timer.phase !== "idle")
    })
    
    timer.connect("notify::remaining", () => {
        label.label = formatTime(timer.remaining)
    })

    timer.connect("timer-stopped", () => {
        pause_icon.visible = true
    })

    timer.connect("timer-started", () => {
        pause_icon.visible = false
    })

    const rightClick = new Gtk.GestureClick({ button: 3 })
    rightClick.connect("pressed", () => timer.toggle())
    btn.add_controller(rightClick)

    btn.connect("clicked", () => popup.popup())

    // Initialen Zustand setzen
    btn.cssClasses = ["bar__btn", "pomodoro-widget", `phase--${timer.phase}`]

    return btn
}
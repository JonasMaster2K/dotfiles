import { Gtk } from "ags/gtk4"
import BarButton from "../../components/BarButton"
import PomodoroTimer from "../../services/PomodoroTimer"
import PomodoroPopup from "./PomodoroPopup"
import formatTime from "../../utils/formatTime"

const timer = new PomodoroTimer()

export default function PomodoroWidget(): Gtk.Widget {
    const btn = new BarButton({ iconName: timer.icon_name })

    const popup = PomodoroPopup(()=> timer)
    popup.set_parent(btn)

    //===============================
    //---------- STRUCTURE ----------
    //===============================
    const overlay = new Gtk.Overlay({
        hexpand: true,
        visible: false,
    })
    btn.content.append(overlay)

    const label = new Gtk.Label({
        label: formatTime(timer.remaining),
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    })
    overlay.set_child(label)

    const pause_icon = new Gtk.Image({
        icon_name: "media-playback-pause-symbolic",
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    })
    overlay.add_overlay(pause_icon)

    //===============================
    //-------- FUNCTIONALITY --------
    //===============================
    timer.connect("notify::icon-name", () => {
        timer.phase === "idle" ? btn.cssClasses = ["bar__btn"] : timer.phase === "work" ? btn.cssClasses = ["bar__btn--err"] : btn.cssClasses = ["bar__btn--ok"]
        btn.icon.set_from_icon_name(timer.icon_name)
        timer.phase === "idle" ? overlay.visible = false : overlay.visible = true
    })
    timer.connect("notify::remaining", ()=>{label.label = formatTime(timer.remaining)})

    timer.connect("timer-stopped", ()=>{
        pause_icon.visible = true
    })

    timer.connect("timer-started", ()=>{
        pause_icon.visible = false
    })

    const rightClick = new Gtk.GestureClick({ button: 3 })
    rightClick.connect("pressed", () => timer.toggle())
    btn.add_controller(rightClick)

    btn.connect("clicked", () => popup.popup())

    return btn
}
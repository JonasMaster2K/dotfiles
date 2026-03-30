import { Gtk } from "ags/gtk4"
import TaskBarIconButton from "../components/TaskBarIconButton"
import PomodoroPopover from "../popup-menus/Pomodoro_Popup"

export default function PomodoroWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton("alarm-symbolic")

    const timeLabel = new Gtk.Label({
        css_classes: ["label--meta"],
    })
    btn.extra.append(timeLabel)
    btn.extra.visible = false

    const formatTime = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`

    const { popover } = PomodoroPopover(({ mode, state, remaining }) => {
        btn.icon.icon_name = mode === "work" ? "alarm-symbolic" : "face-smile-symbolic"
        timeLabel.label    = formatTime(remaining)
        btn.extra.visible  = state !== "idle"
        btn.content.homogeneous = !btn.extra.visible
        btn.content.spacing = btn.extra.visible ? 6 : 0
    })

    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    return btn
}
import { Gtk } from "ags/gtk4"

export default function PomodoroPage(): Gtk.Widget {
    return new Gtk.Label({ label: "Pomodoro – TODO" })
}
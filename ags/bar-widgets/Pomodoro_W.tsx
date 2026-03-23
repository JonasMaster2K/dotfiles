import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import AstalNotifd from "gi://AstalNotifd?version=0.1"

const WORK_TIME  = 25 * 60
const BREAK_TIME = 5 * 60

type Mode = "work" | "break"
type State = "idle" | "running" | "paused"

export default function PomodoroWidget(): Gtk.Widget {
    let mode: Mode  = "work"
    let state: State = "idle"
    let remaining   = WORK_TIME
    let timerId: number | null = null

    // == POPOVER CONTENT ===================================================

    // -- Mode indicator ----------------------------------------------------
    const modeLabel = new Gtk.Label({
        css_classes: ["pomodoro__mode", "text--sm", "text--semibold"],
        label: "Work",
    })

    // -- Timer display -----------------------------------------------------
    const timerLabel = new Gtk.Label({
        css_classes: ["pomodoro__timer"],
        label: "25:00",
    })

    // -- Progress bar ------------------------------------------------------
    const progress = new Gtk.ProgressBar({
        css_classes: ["pomodoro__progress"],
        hexpand: true,
        fraction: 0,
    })

    // -- Controls ----------------------------------------------------------
    const startPauseBtn = new Gtk.Button({
        css_classes: ["pomodoro__btn", "pomodoro__btn--primary"],
    })
    const startPauseIcon = new Gtk.Image({ icon_name: "media-playback-start-symbolic", pixel_size: 18 })
    startPauseBtn.set_child(startPauseIcon)

    const resetBtn = new Gtk.Button({
        css_classes: ["pomodoro__btn"],
    })
    resetBtn.set_child(new Gtk.Image({ icon_name: "view-refresh-symbolic", pixel_size: 18 }))

    const switchBtn = new Gtk.Button({
        css_classes: ["pomodoro__btn"],
        tooltip_text: "Switch to break",
    })
    const switchIcon = new Gtk.Image({ icon_name: "media-skip-forward-symbolic", pixel_size: 18 })
    switchBtn.set_child(switchIcon)

    const controls = new Gtk.Box({ spacing: 8, halign: Gtk.Align.CENTER })
    controls.append(resetBtn)
    controls.append(startPauseBtn)
    controls.append(switchBtn)

    const popoverBox = new Gtk.Box({
        css_classes: ["pomodoro__box"],
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 10,
        width_request: 200,
    })
    popoverBox.append(modeLabel)
    popoverBox.append(timerLabel)
    popoverBox.append(progress)
    popoverBox.append(controls)

    const popover = new Gtk.Popover({
        css_classes: ["pomodoro-popover"],
        has_arrow: false,
    })
    popover.set_child(popoverBox)

    // == STATUSBAR BUTTON ==================================================
    const barLabel = new Gtk.Label({
        css_classes: ["pomodoro__bar-label", "text--xs"],
        label: "25:00",
        visible: false,
    })
    const barIcon = new Gtk.Image({
        icon_name: "alarm-symbolic",
        pixel_size: 16,
    })

    const barBox = new Gtk.Box({ spacing: 4, valign: Gtk.Align.CENTER })
    barBox.append(barIcon)
    barBox.append(barLabel)

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget", "pomodoro-status"],
        valign: Gtk.Align.CENTER,
        tooltip_text: "Pomodoro",
    })
    btn.set_child(barBox)
    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    // == LOGIC =============================================================
    const formatTime = (s: number) => {
        const m = Math.floor(s / 60)
        return `${m}:${String(s % 60).padStart(2, "0")}`
    }

    const total = () => mode === "work" ? WORK_TIME : BREAK_TIME

    const updateUI = () => {
        const fmt = formatTime(remaining)
        timerLabel.label = fmt
        barLabel.label = fmt
        progress.fraction = 1 - remaining / total()
        modeLabel.label = mode === "work" ? "Work" : "Break"
        startPauseIcon.icon_name = state === "running"
            ? "media-playback-pause-symbolic"
            : "media-playback-start-symbolic"
        barLabel.visible = state !== "idle"
        barIcon.icon_name = mode === "work" ? "alarm-symbolic" : "face-smile-symbolic"
        switchBtn.tooltip_text = mode === "work" ? "Switch to break" : "Switch to work"
    }

    const notify = (title: string, body: string) => {
        try {
            GLib.spawn_command_line_async(
                `notify-send "${title}" "${body}" -i alarm-symbolic`
            )
        } catch {}
    }

    const playSound = () => {
        try {
            GLib.spawn_command_line_async(
                "paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
            )
        } catch {}
    }

    const stopTimer = () => {
        if (timerId !== null) { GLib.source_remove(timerId); timerId = null }
    }

    const onFinish = () => {
        stopTimer()
        state = "idle"
        if (mode === "work") {
            notify("Pomodoro done! 🍅", "Time for a break.")
            playSound()
            mode = "break"
            remaining = BREAK_TIME
        } else {
            notify("Break over!", "Back to work.")
            playSound()
            mode = "work"
            remaining = WORK_TIME
        }
        updateUI()
    }

    const startTimer = () => {
        state = "running"
        timerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
            remaining--
            if (remaining <= 0) {
                onFinish()
                return GLib.SOURCE_REMOVE
            }
            updateUI()
            return GLib.SOURCE_CONTINUE
        })
        updateUI()
    }

    startPauseBtn.connect("clicked", () => {
        if (state === "running") {
            stopTimer()
            state = "paused"
        } else {
            startTimer()
        }
        updateUI()
    })

    resetBtn.connect("clicked", () => {
        stopTimer()
        state = "idle"
        remaining = total()
        updateUI()
    })

    switchBtn.connect("clicked", () => {
        stopTimer()
        state = "idle"
        mode = mode === "work" ? "break" : "work"
        remaining = total()
        updateUI()
    })

    updateUI()
    return btn
}
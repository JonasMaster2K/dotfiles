import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import AstalNotifd from "gi://AstalNotifd?version=0.1"

const WORK_TIME  = 25 * 60
const BREAK_TIME =  5 * 60

type Mode  = "work" | "break"
type State = "idle" | "running" | "paused"

export interface PomodoroState {
    mode: Mode
    state: State
    remaining: number
}

export default function PomodoroPopover(onStateChange: (s: PomodoroState) => void): {
    popover: Gtk.Popover
} {
    let mode: Mode   = "work"
    let state: State = "idle"
    let remaining    = WORK_TIME
    let timerId: number | null = null

    const total      = () => mode === "work" ? WORK_TIME : BREAK_TIME
    const formatTime = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`

    const notifd = AstalNotifd.get_default()

    const notify = (msg: string, onSkip?: () => void, onStop?: () => void) => {
        try {
            GLib.spawn_command_line_async(
                `notify-send "Pomodoro" "${msg}" -A "skip=Skip" -A "stop=Stop" -n "alarm-symbolic"`
            )
        } catch {}

        const id = notifd.connect("notified", (_: any, notifId: number) => {
            const n = notifd.get_notification(notifId)
            if (n?.summary !== "Pomodoro") return
            n.connect("action-invoked", (_: any, action: string) => {
                if (action === "continue") onSkip?.()
                if (action === "stop") onStop?.()
            })
            notifd.disconnect(id)
        })
    }

    // == POPOVER ===========================================================
    const popover = new Gtk.Popover({
        has_arrow: false,
        autohide: true,
        width_request: 260,
        css_classes: ["audio-popover"],
    })
    popover.set_offset(0, 10)

    const revealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 200,
        reveal_child: false,
    })
    popover.set_child(revealer)

    const content = new Gtk.Box({
        css_classes: ["popover--panel"],
        orientation: Gtk.Orientation.VERTICAL,
        hexpand: true,
        spacing: 8,
    })
    revealer.set_child(content)

    // Header
    content.append(new Gtk.Label({
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
        hexpand: true,
        label: "Pomodoro",
    }))
    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // Mode + Timer
    const modeLabel = new Gtk.Label({
        css_classes: ["label--section"],
        halign: Gtk.Align.CENTER,
        label: "Work 🍅",
    })
    content.append(modeLabel)

    const timerLabel = new Gtk.Label({
        css_classes: ["pomodoro__timer"],
        halign: Gtk.Align.CENTER,
        label: "25:00",
    })
    content.append(timerLabel)

    const progress = new Gtk.ProgressBar({
        css_classes: ["pomodoro__progress"],
        hexpand: true,
        fraction: 0,
    })
    content.append(progress)
    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // Controls
    const makeBtn = (icon: string) => {
        const b = new Gtk.Button({ css_classes: ["btn", "btn--outlined"] })
        b.set_child(new Gtk.Image({ icon_name: icon, pixel_size: 16 }))
        return b
    }

    const startPauseBtn = makeBtn("media-playback-start-symbolic")
    const stopBtn       = makeBtn("media-playback-stop-symbolic")
    const skipBtn       = makeBtn("media-skip-forward-symbolic")

    const controls = new Gtk.Box({ spacing: 8, halign: Gtk.Align.CENTER })
    controls.append(stopBtn)
    controls.append(startPauseBtn)
    controls.append(skipBtn)
    content.append(controls)

    // == LOGIC =============================================================
    const emit = () => onStateChange({ mode, state, remaining })

    const updateUI = () => {
        timerLabel.label  = formatTime(remaining)
        modeLabel.label   = mode === "work" ? "Work 🍅" : "Break ☕"
        progress.fraction = 1 - remaining / total()
        ;(startPauseBtn.get_child() as Gtk.Image).icon_name = state === "running"
            ? "media-playback-pause-symbolic"
            : "media-playback-start-symbolic"
        stopBtn.sensitive = state !== "idle"
        emit()
    }

    const stopTimer = () => {
        if (timerId !== null) { GLib.source_remove(timerId); timerId = null }
    }

    const skip = () => {
        stopTimer()
        state     = "idle"
        mode      = mode === "work" ? "break" : "work"
        remaining = total()
        updateUI()
        start()
    }

    const stop = () => {
        stopTimer()
        state     = "idle"
        mode      = "work"
        remaining = WORK_TIME
        updateUI()
    }

    const start = () => {
        state   = "running"
        timerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
            remaining--
            if (remaining <= 0) {
                stopTimer()
                state = "idle"
                notify(
                    mode === "work" ? "Break time! ☕" : "Back to work! 🍅",
                    () => skip(),
                    () => stop(),
                )
                mode      = mode === "work" ? "break" : "work"
                remaining = total()
                updateUI()
                return GLib.SOURCE_REMOVE
            }
            updateUI()
            return GLib.SOURCE_CONTINUE
        })
        updateUI()
    }

    startPauseBtn.connect("clicked", () => state === "running" ? (stopTimer(), state = "paused", updateUI()) : start())
    stopBtn.connect("clicked",       () => stop())
    skipBtn.connect("clicked",       () => skip())

    popover.connect("notify::visible", () => {
        revealer.reveal_child = popover.visible
    })

    updateUI()
    return { popover }
}
import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib?version=2.0"
import PomodoroTimer from "../../services/PomodoroTimer"
import Popup from "../../components/Popup"

function spin(
    label: string,
    value: number,
    min: number,
    max: number,
    step: number,
    onChange: (v: number) => void
): { row: Gtk.Box, button: Gtk.SpinButton } {
    const row    = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 4 })
    const lbl    = new Gtk.Label({ label, xalign: 0, css_classes: ["text--sm", "text--muted"] })
    const button = new Gtk.SpinButton({
        adjustment: new Gtk.Adjustment({ value, lower: min, upper: max, step_increment: step }),
        css_classes: ["entry--default"],
    })
    button.connect("value-changed", () => onChange(button.get_value()))
    row.append(button)
    row.append(lbl)
    return { row, button }
}

function spinLabeled(
    label: string,
    value: number,
    min: number,
    max: number,
    step: number,
    onChange: (v: number) => void
): { row: Gtk.Box, button: Gtk.SpinButton } {
    const row    = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    const lbl    = new Gtk.Label({ label, hexpand: true, xalign: 0, css_classes: ["text--sm", "text--muted"] })
    const button = new Gtk.SpinButton({
        adjustment: new Gtk.Adjustment({ value, lower: min, upper: max, step_increment: step }),
        css_classes: ["entry--default"],
    })
    button.connect("value-changed", () => onChange(button.get_value()))
    row.append(lbl)
    row.append(button)
    return { row, button }
}

function actionBtn(label: string, cssClass: string, onClick: () => void): Gtk.Button {
    const b = new Gtk.Button({ label, css_classes: ["btn", cssClass] })
    b.connect("clicked", onClick)
    return b
}

function phaseBtn(label: string, onClick: () => void): Gtk.Button {
    const b = new Gtk.Button({ label, css_classes: ["btn", "btn--outlined"] })
    b.connect("clicked", onClick)
    return b
}

function sectionLabel(text: string): Gtk.Label {
    return new Gtk.Label({ label: text, xalign: 0, css_classes: ["text--xs", "text--muted"] })
}

function formatTime(seconds: number): string {
    let h = Math.floor(seconds / 3600);
    let m = Math.floor((seconds % 3600) / 60);
    let sec = seconds % 60;
    return `${h}h ${m}min ${sec}sec`
}

export default function PomodoroPopup(getPomodoro: () => PomodoroTimer | null): Popup {
    const timer = getPomodoro()!
    const popup = new Popup({ minWidth: 500, minHeight: 720, header: false, footer: false })
    const box   = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 12, margin_top: 16, margin_bottom: 16, margin_start: 16, margin_end: 16 })

    // ---- Status Card ----
    const statusCard    = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4, css_classes: ["card", "card--accent"] })
    const phaseLabel    = new Gtk.Label({ label: timer.phase.toUpperCase(), xalign: 0, css_classes: ["text--sm"] })
    const remainingLabel= new Gtk.Label({ label: `${formatTime(timer.remaining)}`, xalign: 0, css_classes: ["text--xl"] })
    const fractionLabel = new Gtk.Label({ label: `${(timer.fraction * 100).toFixed(0)}%`, xalign: 0, css_classes: ["text--sm", "text--muted"] })
    const blockDurLabel = new Gtk.Label({ label: `Block: ${formatTime(timer.blockDuration)}`, xalign: 0, css_classes: ["text--sm", "text--muted"] })
    const statsRow      = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    const sessionsLabel = new Gtk.Label({ label: `Sessions ${timer.sessions}`, css_classes: ["text--sm", "text--muted"] })
    const totalLabel    = new Gtk.Label({ label: `Total ${timer.totalSessions}`, css_classes: ["text--sm", "text--muted"] })
    const blocksLabel   = new Gtk.Label({ label: `Blocks ${timer.blockCount}`, css_classes: ["text--sm", "text--muted"] })
    statsRow.append(sessionsLabel)
    statsRow.append(totalLabel)
    statsRow.append(blocksLabel)
    statusCard.append(phaseLabel)
    statusCard.append(remainingLabel)
    statusCard.append(fractionLabel)
    statusCard.append(blockDurLabel)
    statusCard.append(statsRow)

    const updateStatus = () => {
        phaseLabel.label     = timer.phase.toUpperCase()
        remainingLabel.label = `${formatTime(timer.remaining)}`
        fractionLabel.label  = `${(timer.fraction * 100).toFixed(0)}%`
        blockDurLabel.label  = `Block: ${formatTime(timer.blockDuration)}`
        sessionsLabel.label  = `Sessions ${timer.sessions}`
        totalLabel.label     = `Total ${timer.totalSessions}`
        blocksLabel.label    = `Blocks ${timer.blockCount}`
    }

    timer.connect("tick",          updateStatus)
    timer.connect("phase-changed", updateStatus)
    timer.connect("reset",         updateStatus)
    timer.connect("config-changed",updateStatus)

    // ---- Actions ----
    const actionBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 4, homogeneous: true })
    for (const [label, cls, action] of [
        ["Toggle",    "btn--accent",   () => timer.toggle()],
        ["Skip",      "btn--outlined", () => timer.skipPhase()],
        ["Reset",     "btn--outlined", () => timer.reset()],
        ["Reset All", "btn--danger",   () => timer.resetAll()],
    ] as [string, string, () => void][])
        actionBox.append(actionBtn(label, cls, action))

    const phaseBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 4, homogeneous: true })
    for (const phase of ["work", "short-break", "long-break", "idle"] as const)
        phaseBox.append(phaseBtn(phase, () => timer.setPhase(phase)))

    // ---- Settings ----
    let updatingFromTimer = false

    const workSpin      = spinLabeled("Work (s)",           timer.workDuration,       1, 3600, 1, v => { if (!updatingFromTimer)    timer.workDuration       = v })
    const shortBreakSpin= spinLabeled("Short Break (s)",    timer.shortBreakDuration, 1, 3600, 1, v => { if (!updatingFromTimer)    timer.shortBreakDuration = v })
    const longBreakSpin = spinLabeled("Long Break (s)",     timer.longBreakDuration,  1, 3600, 1, v => { if (!updatingFromTimer)    timer.longBreakDuration  = v })
    const untilLongSpin = spinLabeled("Until Long",         timer.sessionsUntilLong,  1, 20,   1, v => { if (!updatingFromTimer)    timer.sessionsUntilLong  = v })
    const targetSesSpin = spinLabeled("Sessions per Block", timer.sessionsPerBlock,   0, 100,  1, v => { if (!updatingFromTimer)    timer.sessionsPerBlock   = v })

    // Duration h/m/s
    let durH = Math.floor(timer.targetDuration / 3600)
    let durM = Math.floor((timer.targetDuration % 3600) / 60)
    let durS = timer.targetDuration % 60

    const applyDuration = () => { if (!updatingFromTimer) timer.setDuration(durH * 3600 + durM * 60 + durS) }

    const durHourSpin = spin("h", durH, 0, 23,  1, v => { durH = v; applyDuration() })
    const durMinSpin  = spin("m", durM, 0, 59,  5, v => { durM = v; applyDuration() })
    const durSecSpin  = spin("s", durS, 0, 59, 10, v => { durS = v; applyDuration() })

    const durRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    const durLbl = new Gtk.Label({ label: "Set Duration", hexpand: true, xalign: 0, css_classes: ["text--sm", "text--muted"] })
    const durInputs = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 4 })
    durInputs.append(durHourSpin.row)
    durInputs.append(durMinSpin.row)
    durInputs.append(durSecSpin.row)
    durRow.append(durLbl)
    durRow.append(durInputs)

    timer.connect("config-changed", () => {
        updatingFromTimer = true
        workSpin      .button.set_value(timer.workDuration)
        shortBreakSpin.button.set_value(timer.shortBreakDuration)
        longBreakSpin .button.set_value(timer.longBreakDuration)
        targetSesSpin .button.set_value(timer.sessionsPerBlock)
        durHourSpin   .button.set_value(Math.floor(timer.targetDuration / 3600))
        durMinSpin    .button.set_value(Math.floor((timer.targetDuration % 3600) / 60))
        durSecSpin    .button.set_value(timer.targetDuration % 60)
        GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
            updatingFromTimer = false
            return GLib.SOURCE_REMOVE
        })
    })

    const autoSwitch = new Gtk.Switch({ active: timer.autoStart })
    autoSwitch.connect("state-set", (_: any, state: boolean) => { timer.autoStart = state; return false })
    const autoRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    autoRow.append(new Gtk.Label({ label: "Auto Start", hexpand: true, xalign: 0, css_classes: ["text--sm", "text--muted"] }))
    autoRow.append(autoSwitch)

    const settingsCard = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8, css_classes: ["card"] })
    for (const w of [workSpin.row, shortBreakSpin.row, longBreakSpin.row, untilLongSpin.row, targetSesSpin.row, durRow, autoRow])
        settingsCard.append(w)

    // ---- Event Log ----
    const log     = new Gtk.Label({ label: "—", wrap: true, xalign: 0, css_classes: ["text--sm", "text--muted"] })
    const logCard = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4, css_classes: ["card"] })
    logCard.append(log)

    const logEvent = (msg: string) => log.set_label(`[${new Date().toLocaleTimeString()}] ${msg}`)
    timer.connect("started",           () => logEvent("started"))
    timer.connect("paused",            () => logEvent("paused"))
    timer.connect("session-completed", () => logEvent("session-completed"))
    timer.connect("block-completed",   () => logEvent("block-completed"))
    timer.connect("target-reached",    () => logEvent("🎯 target-reached"))
    timer.connect("phase-completed",   (_: any, p: string) => logEvent(`phase-completed: ${p}`))

    // ---- Append All ----
    const sep = () => new Gtk.Separator({ orientation: Gtk.Orientation.HORIZONTAL })

    for (const w of [
        statusCard,
        sep(),
        sectionLabel("ACTIONS"),
        actionBox,
        sectionLabel("SET PHASE"),
        phaseBox,
        sep(),
        sectionLabel("SETTINGS"),
        settingsCard,
        sep(),
        sectionLabel("EVENTS"),
        logCard,
    ]) box.append(w)

    const scroll = new Gtk.ScrolledWindow({ vexpand: true, min_content_height: 500 })
    scroll.set_child(box)
    popup.body.append(scroll)
    return popup
}
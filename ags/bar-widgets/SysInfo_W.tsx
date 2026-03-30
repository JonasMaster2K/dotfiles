import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib?version=2.0"
import Usage from "../services/SystemInfoService"

const usage = Usage.get_default()

function bytesToGB(bytes: number, decimals = 1) {
    return (bytes / 1073741824).toFixed(decimals)
}

function formatNet(bytes: number) {
    if (bytes > 1000000) return `${(bytes / 1000000).toFixed(1)}MB/s`
    if (bytes > 1000)    return `${(bytes / 1000).toFixed(0)}KB/s`
    return `${bytes}B/s`
}

export default function SysInfoWidget(): Gtk.Widget {
    // LABELS =================================================
    const netRxLabel   = new Gtk.Label({ css_classes: ["label--meta"], valign: Gtk.Align.CENTER })
    const netTxLabel   = new Gtk.Label({ css_classes: ["label--meta"], valign: Gtk.Align.CENTER })
    const cpuLabel     = new Gtk.Label({ css_classes: ["label--meta"], valign: Gtk.Align.CENTER })
    const cpuTempLabel = new Gtk.Label({ css_classes: ["label--meta"], valign: Gtk.Align.CENTER })
    const memLabel     = new Gtk.Label({ css_classes: ["label--meta"], valign: Gtk.Align.CENTER })

    // STRUCTURE ==============================================
    const sep = () => new Gtk.Label({ css_classes: ["text--tertiary"], label: "|" })

    const makeBox = (iconOrLabel: string, label: Gtk.Label, isIcon = false) => {
        const box = new Gtk.Box({ spacing: 4, valign: Gtk.Align.CENTER })
        if (isIcon) {
            box.append(new Gtk.Image({ css_classes: ["icon--tertiary"], icon_name: iconOrLabel, pixel_size: 14 }))
        } else {
            box.append(new Gtk.Label({ css_classes: ["text--tertiary"], label: iconOrLabel }))
        }
        box.append(label)
        return box
    }

    const revealerBox = new Gtk.Box({ valign: Gtk.Align.CENTER, spacing: 7 })
    revealerBox.append(makeBox("network-receive-symbolic",  netRxLabel,   true))
    revealerBox.append(makeBox("network-transmit-symbolic", netTxLabel,   true))
    revealerBox.append(sep())
    revealerBox.append(makeBox("\udb80\udf5b", cpuLabel))
    revealerBox.append(makeBox("\uf2c9",       cpuTempLabel))
    revealerBox.append(sep())
    revealerBox.append(makeBox("\uefc5 ",      memLabel))

    const revealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_LEFT,
        reveal_child: false,
        visible: false,
    })
    revealer.set_child(revealerBox)

    const box = new Gtk.Box({ spacing: 6, valign: Gtk.Align.CENTER, margin_start: 3, margin_end: 3 })
    box.append(revealer)
    box.append(new Gtk.Image({ icon_name: "computer-symbolic", pixel_size: 16, valign: Gtk.Align.CENTER }))

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
    })
    btn.set_child(box)

    // FUNCTIONALITY ==========================================
    const updateMem = () => {
        const total = bytesToGB(usage.memoryTotal)
        const used  = bytesToGB(usage.memoryTotal - usage.memoryAvailable)
        memLabel.label = `${used}/${total}GB`
    }

    const updateAll = () => {
        netRxLabel.label   = formatNet(usage.netRx)
        netTxLabel.label   = formatNet(usage.netTx)
        cpuLabel.label     = `${Math.round(usage.cpuUsage * 100)}%`
        cpuTempLabel.label = usage.cpuTemp > 0 ? `${usage.cpuTemp}°C` : `--°C`
        updateMem()
    }

    updateAll()
    usage.connect("notify::net-rx",           () => { netRxLabel.label   = formatNet(usage.netRx) })
    usage.connect("notify::net-tx",           () => { netTxLabel.label   = formatNet(usage.netTx) })
    usage.connect("notify::cpu-usage",        () => { cpuLabel.label     = `${Math.round(usage.cpuUsage * 100)}%` })
    usage.connect("notify::cpu-temp",         () => { cpuTempLabel.label = usage.cpuTemp > 0 ? `${usage.cpuTemp}°C` : `--°C` })
    usage.connect("notify::memory-total",     updateMem)
    usage.connect("notify::memory-available", updateMem)

    let isRevealed = false
    btn.connect("clicked", () => {
        isRevealed = !isRevealed
        if (isRevealed) revealer.visible = true
        revealer.reveal_child = isRevealed
        if (!isRevealed) {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
                revealer.visible = false
                return GLib.SOURCE_REMOVE
            })
        }
    })

    return btn
}
import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib?version=2.0"
import Usage from "../../services/SystemInfoService"

const usage = Usage.get_default()

const bytesToGB = (bytes: number, decimals = 1) =>
    (bytes / 1073741824).toFixed(decimals)

const formatNet = (bytes: number) =>
    bytes > 1000000 ? `${(bytes / 1000000).toFixed(1)}MB/s`
    : bytes > 1000  ? `${(bytes / 1000).toFixed(0)}KB/s`
    : `${bytes}B/s`

function MetaLabel() {
    return <label css_classes={["label--meta"]} valign={Gtk.Align.CENTER} /> as Gtk.Label
}

function Sep() {
    return <label css_classes={["text--tertiary"]} label="|" valign={Gtk.Align.CENTER} />
}

function StatBox({ icon, label, isIcon = false }: { icon: string, label: Gtk.Label, isIcon?: boolean }) {
    return (
        <box spacing={4} valign={Gtk.Align.CENTER}>
            {isIcon
                ? <image css_classes={["icon--secondary"]} icon_name={icon} pixel_size={14} valign={Gtk.Align.CENTER} />
                : <label css_classes={["text--primary"]} label={icon} valign={Gtk.Align.CENTER} />
            }
            {label}
        </box>
    )
}

export default function SysInfoWidget(): Gtk.Widget {
    const netRxLabel   = MetaLabel()
    const netTxLabel   = MetaLabel()
    const cpuLabel     = MetaLabel()
    const cpuTempLabel = MetaLabel()
    const memLabel     = MetaLabel()

    const updateMem = () => {
        memLabel.label = `${bytesToGB(usage.memoryTotal - usage.memoryAvailable)}/${bytesToGB(usage.memoryTotal)}GB`
    }

    usage.connect("notify::net-rx",           () => netRxLabel.label   = formatNet(usage.netRx))
    usage.connect("notify::net-tx",           () => netTxLabel.label   = formatNet(usage.netTx))
    usage.connect("notify::cpu-usage",        () => cpuLabel.label     = `${Math.round(usage.cpuUsage * 100)}%`)
    usage.connect("notify::cpu-temp",         () => cpuTempLabel.label = usage.cpuTemp > 0 ? `${usage.cpuTemp}°C` : `--°C`)
    usage.connect("notify::memory-total",     updateMem)
    usage.connect("notify::memory-available", updateMem)

    netRxLabel.label   = formatNet(usage.netRx)
    netTxLabel.label   = formatNet(usage.netTx)
    cpuLabel.label     = `${Math.round(usage.cpuUsage * 100)}%`
    cpuTempLabel.label = usage.cpuTemp > 0 ? `${usage.cpuTemp}°C` : `--°C`
    updateMem()

    let isRevealed = false

    const revealer = (
        <revealer
            transition_type={Gtk.RevealerTransitionType.SLIDE_LEFT}
            reveal_child={false}
            visible={false}
            margin_end={4}
            valign={Gtk.Align.CENTER}
            vexpand={false}
        >
            <box valign={Gtk.Align.CENTER} spacing={7}>
                <StatBox icon="network-receive-symbolic"     label={netRxLabel}   isIcon />
                <StatBox icon="network-transmit-symbolic"    label={netTxLabel}   isIcon />
                <Sep />
                <StatBox icon="cpu-symbolic"                 label={cpuLabel}     isIcon />
                <StatBox icon="sensors-temperature-symbolic" label={cpuTempLabel} isIcon />
                <Sep />
                <StatBox icon="ram-symbolic"                 label={memLabel}     isIcon />
            </box>
        </revealer>
    ) as Gtk.Revealer

    const btn = (
        <button
            css_classes={["statusbar-widget"]}
            valign={Gtk.Align.CENTER}
            onClicked={() => {
                isRevealed = !isRevealed
                if (isRevealed) revealer.visible = true
                revealer.reveal_child = isRevealed
                if (!isRevealed) {
                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
                        revealer.visible = false
                        return GLib.SOURCE_REMOVE
                    })
                }
            }}
        >
            <box spacing={6} valign={Gtk.Align.CENTER} margin_start={3} margin_end={3}>
                {revealer}
                <image icon_name="computer-symbolic" pixel_size={16} valign={Gtk.Align.CENTER} />
            </box>
        </button>
    )

    return btn as Gtk.Button
}
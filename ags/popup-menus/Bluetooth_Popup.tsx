import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import AstalBluetooth from "gi://AstalBluetooth"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import { createBluetoothAgent, unregisterBluetoothAgent } from "../services/Bluetoothagent"

const PAIRING_TIMEOUT = 60

export default function BluetoothPopup(bluetooth: AstalBluetooth.Bluetooth): Gtk.Popover {
    // ============================================================
    // STRUCTURE
    // ============================================================
    const popover = new Gtk.Popover({
        has_arrow: false,
        autohide: true,
        width_request: 400,
        css_classes: ["bluetooth-popover"],
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

    // HEADER =================================================
    const headerRow = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        hexpand: true,
        spacing: 8,
    })
    content.append(headerRow)

    const headerLabel = new Gtk.Label({
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        label: "Bluetooth",
    })
    headerRow.append(headerLabel)

    const adapterLabel = new Gtk.Label({
        css_classes: ["label--meta"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        label: "",
    })
    headerRow.append(adapterLabel)

    const toggle = new Gtk.Switch({
        halign: Gtk.Align.END,
        valign: Gtk.Align.CENTER,
    })
    headerRow.append(toggle)

    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // BODY ===================================================
    const scrollable = new Gtk.ScrolledWindow({
        hexpand: true,
        vexpand: true,
        height_request: 200,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
    })
    content.append(scrollable)

    const deviceList = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        hexpand: true,
        spacing: 4,
    })
    scrollable.set_child(deviceList)

    // PAIRING REVEALER =======================================
    const pairingRevealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 200,
        reveal_child: false,
    })
    content.append(pairingRevealer)

    const pairingBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    pairingRevealer.set_child(pairingBox)
    pairingBox.append(new Gtk.Separator({ css_classes: ["divider"] }))

    const pairingProgressBar = new Gtk.ProgressBar({
        hexpand: true,
        css_classes: ["pairing-bar"],
    })
    pairingBox.append(pairingProgressBar)

    const pairingRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    pairingBox.append(pairingRow)

    const pairingLabel = new Gtk.Label({
        css_classes: ["label--meta"],
        halign: Gtk.Align.START,
        hexpand: true,
        label: "",
    })
    pairingRow.append(pairingLabel)

    const confirmBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated"], label: "✓" })
    pairingRow.append(confirmBtn)

    const rejectBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--danger"], label: "✗" })
    pairingRow.append(rejectBtn)

    // PIN REVEALER ===========================================
    const pinRevealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 200,
        reveal_child: false,
    })
    content.append(pinRevealer)

    const pinBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    pinRevealer.set_child(pinBox)
    pinBox.append(new Gtk.Separator({ css_classes: ["divider"] }))

    const pinProgressBar = new Gtk.ProgressBar({
        hexpand: true,
        css_classes: ["pairing-bar"],
    })
    pinBox.append(pinProgressBar)

    const pinRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    pinBox.append(pinRow)

    const pinLabel = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.START, label: "PIN:" })
    pinRow.append(pinLabel)

    const pinEntry = new Gtk.Entry({
        hexpand: true,
        placeholder_text: "Enter PIN...",
        css_classes: ["entry--default"],
    })
    pinRow.append(pinEntry)

    const pinConfirmBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated"], label: "✓" })
    pinRow.append(pinConfirmBtn)

    const pinRejectBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--danger"], label: "✗" })
    pinRow.append(pinRejectBtn)

    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // FOOTER =================================================
    const footer = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 4 })
    content.append(footer)

    const footerSpacer = new Gtk.Box({ hexpand: true })
    footer.append(footerSpacer)

    const scanBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"] })
    footer.append(scanBtn)

    const scanIcon = new Gtk.Image({ css_classes: ["rescan-icon"], icon_name: "view-refresh-symbolic" })
    scanBtn.set_child(scanIcon)

    const settingsBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"] })
    footer.append(settingsBtn)
    settingsBtn.set_child(new Gtk.Image({ icon_name: "preferences-system-symbolic" }))

    // ============================================================
    // FUNCTIONALITY
    // ============================================================
    type Device = AstalBluetooth.Device

    // HELPERS ================================================
    const makeIconBtn = (iconName: string, small: boolean = false, hoverStyle: string = "btn--elevated", tooltip: string = "") => {
        const btn = new Gtk.Button({
            css_classes: small
                ? ["btn", hoverStyle, "btn--round--sm"]
                : ["btn", hoverStyle, "btn--round"],
            valign: Gtk.Align.CENTER,
            tooltip_text: tooltip
        })
        const icon = new Gtk.Image({ icon_name: iconName, pixel_size: 16 })
        btn.set_child(icon)
        return { btn, icon }
    }

    const getSubInfo = (device: Device) => {
        const info: string[] = []
        if (device.connected) info.push("Connected")
        if (device.paired) info.push("Paired")
        if (device.batteryPercentage >= 0) info.push(`🔋 ${Math.round(device.batteryPercentage * 100)}%`)
        return info.join(" · ") || device.address
    }

    const makeTimer = (progressBar: Gtk.ProgressBar, onTimeout: () => void) => {
        let timer: number | null = null
        const start = () => {
            let elapsed = 0
            progressBar.fraction = 1
            if (timer) GLib.source_remove(timer)
            timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
                elapsed += 0.5
                progressBar.fraction = 1 - (elapsed / PAIRING_TIMEOUT)
                if (elapsed >= PAIRING_TIMEOUT) { timer = null; onTimeout(); return GLib.SOURCE_REMOVE }
                return GLib.SOURCE_CONTINUE
            })
        }
        const stop = () => { if (timer) { GLib.source_remove(timer); timer = null } }
        return { start, stop }
    }

    // PAIRING UI =============================================
    let pendingConfirm: (() => void) | null = null
    let pendingReject: (() => void) | null = null

    const pairingTimer = makeTimer(pairingProgressBar, () => hidePairingUI())

    const showPairingUI = (label: string, confirm: (() => void) | null, reject: (() => void) | null) => {
        pendingConfirm = confirm
        pendingReject = reject
        pairingLabel.label = label
        confirmBtn.visible = confirm !== null
        rejectBtn.visible = reject !== null
        pairingRevealer.reveal_child = true
        pairingTimer.start()
    }

    const hidePairingUI = () => {
        pairingTimer.stop()
        pairingRevealer.reveal_child = false
        pendingConfirm = null
        pendingReject = null
    }

    confirmBtn.connect("clicked", () => { pendingConfirm?.(); hidePairingUI() })
    rejectBtn.connect("clicked", () => { pendingReject?.(); hidePairingUI() })

    // PIN UI =================================================
    let pendingPinResolve: ((pin: string) => void) | null = null
    let pendingPinReject: (() => void) | null = null

    const pinTimer = makeTimer(pinProgressBar, () => hidePinUI())

    const showPinUI = (resolve: (pin: string) => void, reject: () => void) => {
        pendingPinResolve = resolve
        pendingPinReject = reject
        pinEntry.text = ""
        pinRevealer.reveal_child = true
        pinEntry.grab_focus()
        pinTimer.start()
    }

    const hidePinUI = () => {
        pinTimer.stop()
        pinRevealer.reveal_child = false
        pendingPinResolve = null
        pendingPinReject = null
    }

    pinConfirmBtn.connect("clicked", () => { pendingPinResolve?.(pinEntry.text); hidePinUI() })
    pinRejectBtn.connect("clicked", () => { pendingPinReject?.(); hidePinUI() })
    pinEntry.connect("activate", () => { pendingPinResolve?.(pinEntry.text); hidePinUI() })

    // AGENT ================================================
    const dbus = createBluetoothAgent(showPairingUI, showPinUI, hidePairingUI, hidePinUI)

    // DEVICE LIST ============================================
    const makeRow = (device: Device) => {
        const row = new Gtk.Box({
            css_classes: ["card"],
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 6,
        })

        const deviceIcon = new Gtk.Image({ icon_name: device.icon ?? "bluetooth-symbolic" })
        row.append(deviceIcon)

        const infoBox = new Gtk.Box({
            orientation: Gtk.Orientation.VERTICAL,
            hexpand: true,
            valign: Gtk.Align.CENTER,
        })

        const nameLabel = new Gtk.Label({
            css_classes: ["label--subtitle"],
            label: device.alias ?? device.name ?? device.address,
            halign: Gtk.Align.START,
            hexpand: true,
            ellipsize: 3,
            max_width_chars: 30,
        })
        infoBox.append(nameLabel)

        const subLabel = new Gtk.Label({
            css_classes: ["label--meta"],
            label: getSubInfo(device),
            halign: Gtk.Align.START,
            hexpand: true,
            ellipsize: 3,
            max_width_chars: 30,
        })
        infoBox.append(subLabel)
        row.append(infoBox)

        const { btn: connectBtn, icon: connectIcon } = makeIconBtn(
            device.connected ? "network-wired-disconnected-symbolic" : "bluetooth-active-symbolic",
            true,
            "btn--elevated",
            device.connected ? "Disconnect" : "Connect"
        )
        connectBtn.connect("clicked", () =>
            execAsync(["bluetoothctl", device.connected ? "disconnect" : "connect", device.address]).catch(console.error)
        )
        device.connect("notify::connected", () => {
            connectIcon.icon_name = device.connected ? "network-wired-disconnected-symbolic" : "bluetooth-active-symbolic"
            subLabel.label = getSubInfo(device)
        })
        row.append(connectBtn)

        const { btn: trustBtn, icon: trustIcon } = makeIconBtn(
            device.trusted ? "security-high-symbolic" : "security-low-symbolic",
            true,
            "btn--warn",
            device.trusted ? "Untrust" : "Trust"
        )
        trustBtn.connect("clicked", () =>
            execAsync(["bluetoothctl", device.trusted ? "untrust" : "trust", device.address]).catch(console.error)
        )
        device.connect("notify::trusted", () => {
            trustIcon.icon_name = device.trusted ? "security-high-symbolic" : "security-low-symbolic"
        })
        row.append(trustBtn)

        const { btn: removeBtn, icon: removeIcon } = makeIconBtn("remove-symbolic", true, "btn--danger", "Unpair")
        removeBtn.visible = device.paired
        removeBtn.connect("clicked", () => {
            execAsync(["bluetoothctl", "remove", device.address]).catch(console.error)
            update()
        })
        device.connect("notify::paired", () => {
            removeBtn.visible = device.paired ? true : false
        })
        row.append(removeBtn)

        return row
    }

    const update = () => {
        toggle.active = bluetooth.isPowered
        adapterLabel.label = bluetooth.adapter?.alias ?? bluetooth.adapter?.name ?? ""

        while (deviceList.get_first_child()) deviceList.remove(deviceList.get_first_child()!)

        const devices = (bluetooth.get_devices() ?? []).filter(d => d.name || d.alias)

        if (devices.length === 0) {
            deviceList.append(new Gtk.Label({
                css_classes: ["label--meta"],
                label: "No devices found",
                halign: Gtk.Align.CENTER,
                valign: Gtk.Align.CENTER,
                vexpand: true,
            }))
            return
        }

        ;[...devices]
            .sort((a, b) => {
                if (a.connected !== b.connected) return a.connected ? -1 : 1
                if (a.paired !== b.paired) return a.paired ? -1 : 1
                return (a.alias ?? a.name ?? "").localeCompare(b.alias ?? b.name ?? "")
            })
            .forEach(d => deviceList.append(makeRow(d)))
    }

    // SIGNALS ================================================
    toggle.connect("notify::active", () => { if (bluetooth.isPowered !== toggle.active) bluetooth.toggle() })
    bluetooth.connect("notify::is-powered", () => { toggle.active = bluetooth.isPowered; update() })

    scanBtn.connect("clicked", () => {
        const a = bluetooth.adapter
        if (!a) return
        a.discovering ? a.stop_discovery() : a.start_discovery()
    })
    bluetooth.adapter?.connect("notify::discovering", () => {
        scanIcon.cssClasses = bluetooth.adapter.discovering ? ["rescan-icon", "anim--spin"] : ["rescan-icon"]
    })

    settingsBtn.connect("clicked", () => execAsync(["blueman-manager"]).catch(console.error))

    bluetooth.connect("device-added", update)
    bluetooth.connect("device-removed", update)
    bluetooth.connect("notify::is-connected", update)

    popover.connect("notify::visible", () => {
        if (popover.visible) { revealer.reveal_child = true; update() }
        else { revealer.reveal_child = false }
    })

    popover.connect("destroy", () => unregisterBluetoothAgent(dbus))

    return popover
}
import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import AstalNetwork from "gi://AstalNetwork"

export default function NetworkPopup(network: AstalNetwork.Network): Gtk.Popover {
    // ========================================================
    // STRUCTURE
    // ========================================================
    const popover = new Gtk.Popover({
        has_arrow: false,
        autohide: true,
        width_request: 400,
        css_classes: ["network-popover"],
    })
    popover.set_offset(0, 10)

    const revealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 350,
        reveal_child: false,
    })
    popover.set_child(revealer)

    const popoverContent = new Gtk.Box({
        css_classes: ["popover--panel"],
        orientation: Gtk.Orientation.VERTICAL,
        hexpand: true,
        spacing: 8,
    })
    revealer.set_child(popoverContent)

    // HEADER =================================================
    const header = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true, spacing: 4 })
    popoverContent.append(header)

    const headerTopRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    header.append(headerTopRow)

    const label = new Gtk.Label({
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        label: "Network-Manager",
    })
    headerTopRow.append(label)

    const ipLabel = new Gtk.Label({
        css_classes: ["label--meta"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        label: "",
    })
    headerTopRow.append(ipLabel)

    const toggle = new Gtk.Switch({
        halign: Gtk.Align.END,
        valign: Gtk.Align.CENTER,
        tooltip_text: "Toggle Wifi",
    })
    headerTopRow.append(toggle)

    const headerBottomRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    header.append(headerBottomRow)

    const connectionType = new Gtk.Image({ icon_name: "network-cellular-connected-symbolic" })
    headerBottomRow.append(connectionType)

    const activeConncetion = new Gtk.Label({
        css_classes: ["label--subtitle"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        label: "Active Connection",
    })
    headerBottomRow.append(activeConncetion)

    popoverContent.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // BODY ===================================================
    const body = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        hexpand: true,
        vexpand: true,
        spacing: 4,
        height_request: 200,
    })
    popoverContent.append(body)

    const acListScrollable = new Gtk.ScrolledWindow({
        hexpand: true,
        vexpand: true,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
    })
    body.append(acListScrollable)

    const acList = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true, spacing: 4 })
    acListScrollable.set_child(acList)

    // PASSWORD REVEALER ======================================
    const pwRevealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 200,
        reveal_child: false,
    })
    popoverContent.append(pwRevealer)

    const pwBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    pwRevealer.set_child(pwBox)
    pwBox.append(new Gtk.Separator({ css_classes: ["divider"] }))

    const pwTopRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    pwBox.append(pwTopRow)

    const pwSsidLabel = new Gtk.Label({
        css_classes: ["label--meta"],
        halign: Gtk.Align.START,
        hexpand: true,
        label: "",
    })
    pwTopRow.append(pwSsidLabel)

    const pwCancelBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round", "btn--danger"], valign: Gtk.Align.CENTER })
    pwCancelBtn.set_child(new Gtk.Image({ icon_name: "window-close-symbolic" }))
    pwTopRow.append(pwCancelBtn)

    const pwEntryRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    pwBox.append(pwEntryRow)

    const pwEntry = new Gtk.Entry({
        css_classes: ["entry--default"],
        placeholder_text: "Password",
        visibility: false,
        input_purpose: Gtk.InputPurpose.PASSWORD,
        hexpand: true,
    })
    pwEntryRow.append(pwEntry)

    const pwToggleBtn = new Gtk.ToggleButton({ css_classes: ["btn", "btn--elevated", "btn--round"], valign: Gtk.Align.CENTER })
    const pwToggleIcon = new Gtk.Image({ icon_name: "view-reveal-symbolic" })
    pwToggleBtn.set_child(pwToggleIcon)
    pwToggleBtn.connect("toggled", () => {
        pwEntry.visibility = pwToggleBtn.active
        pwToggleIcon.icon_name = pwToggleBtn.active ? "view-conceal-symbolic" : "view-reveal-symbolic"
    })
    pwEntryRow.append(pwToggleBtn)

    const pwConnectBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round", "btn--accent"], valign: Gtk.Align.CENTER })
    pwConnectBtn.set_child(new Gtk.Image({ icon_name: "network-wireless-connected-symbolic" }))
    pwEntryRow.append(pwConnectBtn)

    popoverContent.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // FOOTER =================================================
    const footer = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 4 })
    popoverContent.append(footer)

    const showAllBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"], halign: Gtk.Align.START })
    const showAllIcon = new Gtk.Image({ icon_name: "view-reveal-symbolic" })
    showAllBtn.set_child(showAllIcon)
    footer.append(showAllBtn)

    const footerSpacer = new Gtk.Box({ hexpand: true })
    footer.append(footerSpacer)

    const rescanBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"], halign: Gtk.Align.END })
    const rescanIcon = new Gtk.Image({ css_classes: ["rescan-icon"], icon_name: "view-refresh-symbolic" })
    rescanBtn.set_child(rescanIcon)
    footer.append(rescanBtn)

    const settingsBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"], halign: Gtk.Align.END })
    settingsBtn.set_child(new Gtk.Image({ icon_name: "preferences-system-symbolic" }))
    footer.append(settingsBtn)

    // ========================================================
    // FUNCTIONALITY
    // ========================================================
    let showAll = false
    let pendingAp: AccessPoint | null = null

    type AccessPoint = ReturnType<AstalNetwork.Wifi["get_access_points"]>[0]

    const openPasswordRevealer = (ap: AccessPoint) => {
        pendingAp = ap
        pwSsidLabel.label = `Connect to: ${ap.ssid}`
        pwEntry.text = ""
        pwRevealer.reveal_child = true
        pwEntry.grab_focus()
    }

    const closePasswordRevealer = () => {
        pendingAp = null
        pwRevealer.reveal_child = false
        pwEntry.text = ""
        pwEntry.visibility = false
        pwToggleBtn.active = false
    }

    pwCancelBtn.connect("clicked", closePasswordRevealer)
    pwConnectBtn.connect("clicked", () => {
        if (!pendingAp) return
        execAsync(`nmcli device wifi connect "${pendingAp.ssid}" password "${pwEntry.text.replace(/"/g, '\\"')}"`)
        closePasswordRevealer()
    })
    pwEntry.connect("activate", () => pwConnectBtn.emit("clicked"))

    const makeRow = (ap: AccessPoint) => {
        const isActive = ap.ssid === network.wifi?.ssid

        const row = new Gtk.Box({ css_classes: ["card"], orientation: Gtk.Orientation.HORIZONTAL, spacing: 6 })

        row.append(new Gtk.Image({ icon_name: ap.iconName }))
        if (ap.requiresPassword) row.append(new Gtk.Image({ icon_name: "dialog-password-symbolic" }))

        const infoBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true, valign: Gtk.Align.CENTER })

        const ssidLabel = new Gtk.Label({
            css_classes: ["label--subtitle"],
            label: ap.ssid ?? "<hidden>",
            halign: Gtk.Align.START,
            ellipsize: 3,
            max_width_chars: 30,
            hexpand: true,
        })
        const freqLabel = new Gtk.Label({
            css_classes: ["label--meta"],
            label: `${ap.frequency / 1000}GHz`,
            halign: Gtk.Align.START,
        })
        infoBox.append(ssidLabel)
        infoBox.append(freqLabel)
        row.append(infoBox)

        const btn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"], valign: Gtk.Align.CENTER })
        btn.set_child(new Gtk.Image({
            icon_name: isActive ? "network-wired-disconnected-symbolic" : "network-wireless-connected-symbolic",
        }))
        btn.connect("clicked", () => {
            if (isActive) {
                execAsync(`nmcli device disconnect ${network.wifi?.device?.interface}`)
            } else if (ap.requiresPassword) {
                openPasswordRevealer(ap)
            } else {
                execAsync(`nmcli device wifi connect "${ap.ssid}"`)
            }
        })
        row.append(btn)

        return row
    }

    const update = () => {
        if (!network) return

        const isWired = network.primary === AstalNetwork.Primary.WIRED
        connectionType.icon_name = isWired ? network.wired.iconName : network.wifi?.iconName ?? "network-no-route-symbolic"
        activeConncetion.label = isWired ? "LAN" : `${network.wifi?.ssid ?? "Unknown"} (${(network.wifi?.frequency ?? 0) / 1000}GHz)`

        const ip = network.wifi?.device?.ip4Config?.get_addresses()?.[0]?.get_address()
                ?? network.wired?.device?.ip4Config?.get_addresses()?.[0]?.get_address()
        ipLabel.label = ip ?? ""

        while (acList.get_first_child()) acList.remove(acList.get_first_child()!)

        const acs = network.wifi?.get_access_points() ?? []

        if (acs.length === 0) {
            acList.append(new Gtk.Label({
                css_classes: ["label--meta"],
                label: "No networks found",
                halign: Gtk.Align.CENTER,
                valign: Gtk.Align.CENTER,
                vexpand: true,
            }))
            return
        }

        if (showAll) {
            ;[...acs].sort((a, b) => b.strength - a.strength).forEach(ap => acList.append(makeRow(ap)))
        } else {
            const best = new Map<string, AccessPoint>()
            for (const ap of acs) {
                const existing = best.get(ap.ssid)
                if (!existing) {
                    best.set(ap.ssid, ap)
                } else {
                    const prefer5g = ap.frequency > 4000 && existing.frequency <= 4000 && ap.strength >= existing.strength - 20
                    if (prefer5g || ap.strength > existing.strength + 20) best.set(ap.ssid, ap)
                }
            }
            ;[...best.values()].sort((a, b) => b.strength - a.strength).forEach(ap => acList.append(makeRow(ap)))
        }
    }
    update()

    const scan = () => { if (!network.wifi) return; network.wifi.scan(); update() }

    showAllBtn.connect("clicked", () => {
        showAll = !showAll
        showAllIcon.icon_name = showAll ? "view-conceal-symbolic" : "view-reveal-symbolic"
        update()
    })

    popover.connect("notify::visible", () => {
        if (popover.visible) { revealer.reveal_child = true; scan() }
        else { revealer.reveal_child = false }
    })

    toggle.active = network.wifi?.enabled ?? false
    toggle.connect("notify::active", () => { if (network.wifi) network.wifi.enabled = toggle.active })
    network.wifi?.connect("notify::enabled", () => { toggle.active = network.wifi.enabled })

    network.connect("notify::primary", update)
    network.wifi?.connect("notify::icon-name", update)
    network.wifi?.connect("notify::ssid", update)
    network.wired?.connect("notify::icon-name", update)
    network.wifi?.connect("notify::scanning", () => {
        rescanIcon.cssClasses = network.wifi.scanning ? ["rescan-icon", "anim--spin"] : ["rescan-icon"]
        rescanBtn.sensitive = !network.wifi.scanning
        if (!network.wifi.scanning) update()
    })
    rescanBtn.connect("clicked", scan)

    return popover
}
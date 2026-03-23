import { Gtk } from "ags/gtk4"
import AstalBattery from "gi://AstalBattery"
import GLib from "gi://GLib"

const formatTime = (seconds: number) => {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    return h > 0 ? `${h}h ${m}m` : `${m}m`
}

const techNames: Record<number, string> = {
    [AstalBattery.Technology.UNKNOWN]:                "Unknown",
    [AstalBattery.Technology.LITHIUM_ION]:            "Lithium Ion",
    [AstalBattery.Technology.LITHIUM_POLYMER]:        "Lithium Polymer",
    [AstalBattery.Technology.LITHIUM_IRON_PHOSPHATE]: "Lithium Iron Phosphate",
    [AstalBattery.Technology.LEAD_ACID]:              "Lead Acid",
    [AstalBattery.Technology.NICKEL_CADMIUM]:         "Nickel Cadmium",
    [AstalBattery.Technology.NICKEL_METAL_HYDRIDE]:   "Nickel Metal Hydride",
}

const warningNames: Record<number, string> = {
    [AstalBattery.WarningLevel.UNKNOWN]:     "Unknown",
    [AstalBattery.WarningLevel.NONE]:        "None",
    [AstalBattery.WarningLevel.DISCHARGING]: "Discharging",
    [AstalBattery.WarningLevel.LOW]:         "Low",
    [AstalBattery.WarningLevel.CRITICIAL]:   "Critical",
    [AstalBattery.WarningLevel.ACTION]:      "Action",
}

const batteryLevelNames: Record<number, string> = {
    [AstalBattery.BatteryLevel.UNKNOWN]:   "Unknown",
    [AstalBattery.BatteryLevel.NONE]:      "None",
    [AstalBattery.BatteryLevel.LOW]:       "Low",
    [AstalBattery.BatteryLevel.CRITICIAL]: "Critical",
    [AstalBattery.BatteryLevel.NORMAL]:    "Normal",
    [AstalBattery.BatteryLevel.HIGH]:      "High",
    [AstalBattery.BatteryLevel.FULL]:      "Full",
}

const getCurrentProfile = (): string => {
    const [, stdout] = GLib.spawn_command_line_sync("powerprofilesctl get")
    return new TextDecoder().decode(stdout!).trim()
}

const setProfile = (profile: "power-saver" | "balanced" | "performance") => {
    GLib.spawn_command_line_async(`powerprofilesctl set ${profile}`)
}

export default function BatteryPopup(battery: AstalBattery.Device): Gtk.Popover {
    const popover = new Gtk.Popover({
        has_arrow: false,
        autohide: true,
        width_request: 400,
        css_classes: ["battery-popover"],
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
    const headerRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(headerRow)

    const headerLabel = new Gtk.Label({
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        label: "Battery",
    })
    headerRow.append(headerLabel)

    const detailsArrow = new Gtk.Image({ icon_name: "pan-end-symbolic", halign: Gtk.Align.END })
    headerRow.append(detailsArrow)

    const detailsRevealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 200,
        reveal_child: false,
    })
    content.append(detailsRevealer)

    const detailsBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true, spacing: 4, margin_top: 4 })
    detailsRevealer.set_child(detailsBox)

    const clickGesture = new Gtk.GestureClick()
    clickGesture.connect("released", () => {
        const expanded = !detailsRevealer.reveal_child
        detailsRevealer.reveal_child = expanded
        detailsArrow.icon_name = expanded ? "pan-down-symbolic" : "pan-end-symbolic"
    })
    headerRow.add_controller(clickGesture)

    // DETAIL ROWS ============================================
    const makeDetailRow = (key: string, value: string) => {
        const row = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true })
        const k = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.START, hexpand: true, label: key })
        const v = new Gtk.Label({ css_classes: ["label--mono-sm"], halign: Gtk.Align.END, label: value })
        row.append(k)
        row.append(v)
        return { row, v }
    }

    const vendorRow      = makeDetailRow("Vendor",          battery.vendor ?? "—")
    const modelRow       = makeDetailRow("Model",           battery.model ?? "—")
    const serialRow      = makeDetailRow("Serial",          battery.serial ?? "—")
    const nativePathRow  = makeDetailRow("Native Path",     battery.nativePath ?? "—")
    const techRow        = makeDetailRow("Technology",      techNames[battery.technology] ?? "—")
    const designRow      = makeDetailRow("Design Capacity", battery.energyFullDesign > 0 ? `${battery.energyFullDesign.toFixed(1)} Wh` : "—")
    const cyclesRow      = makeDetailRow("Charge Cycles",   battery.chargeCycles?.toString() ?? "—")
    const rechargableRow = makeDetailRow("Rechargeable",    battery.isRechargable ? "Yes" : "No")
    const powerSupplyRow = makeDetailRow("Power Supply",    battery.powerSupply ? "Yes" : "No")
    const deviceTypeRow  = makeDetailRow("Device Type",     battery.deviceTypeName ?? "—")
    const voltageRow     = makeDetailRow("Voltage",         "")
    const capacityRow    = makeDetailRow("Capacity",        "")
    const tempRow        = makeDetailRow("Temperature",     "")
    const warningRow     = makeDetailRow("Warning Level",   "")
    const batteryLvlRow  = makeDetailRow("Battery Level",   "")
    const presentRow     = makeDetailRow("Present",         "")
    const onlineRow      = makeDetailRow("Online",          "")
    const updateTimeRow  = makeDetailRow("Last Updated",    "")

    ;[
        vendorRow, modelRow, serialRow, nativePathRow, techRow, designRow, cyclesRow,
        rechargableRow, powerSupplyRow, deviceTypeRow,
        voltageRow, capacityRow, tempRow, warningRow, batteryLvlRow,
        presentRow, onlineRow, updateTimeRow,
    ].forEach(({ row }) => detailsBox.append(row))

    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // MAIN INFO ==============================================
    const mainRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(mainRow)

    const batteryIcon = new Gtk.Image({ icon_name: "battery-symbolic", valign: Gtk.Align.CENTER })
    mainRow.append(batteryIcon)

    const mainInfoBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true, valign: Gtk.Align.CENTER })
    mainRow.append(mainInfoBox)

    const percentLabel = new Gtk.Label({ css_classes: ["label--subtitle"], halign: Gtk.Align.START, label: "" })
    mainInfoBox.append(percentLabel)

    const stateLabel = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.START, label: "" })
    mainInfoBox.append(stateLabel)

    const batteryBar = new Gtk.ProgressBar({ hexpand: true, css_classes: ["battery-bar"] })
    content.append(batteryBar)

    const timeRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(timeRow)

    const timeLabel   = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.START, hexpand: true, label: "" })
    const energyLabel = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.END, label: "" })
    const rateLabel   = new Gtk.Label({ css_classes: ["label--meta"], halign: Gtk.Align.END, label: "" })
    timeRow.append(timeLabel)
    timeRow.append(energyLabel)
    timeRow.append(rateLabel)

    // POWER PROFILES =========================================
    const profileRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(profileRow)

    const makeProfileBtn = (icon: string, _profile: "power-saver" | "balanced" | "performance") => {
        const btn = new Gtk.Button({
            css_classes: ["btn", "btn--outlined"],
            hexpand: true,
            valign: Gtk.Align.CENTER,
        })
        btn.set_child(new Gtk.Image({ icon_name: icon }))
        return btn
    }

    const powerSaverBtn  = makeProfileBtn("power-profile-power-saver-symbolic",  "power-saver")
    const balancedBtn    = makeProfileBtn("power-profile-balanced-symbolic",      "balanced")
    const performanceBtn = makeProfileBtn("power-profile-performance-symbolic",   "performance")

    profileRow.append(powerSaverBtn)
    profileRow.append(balancedBtn)
    profileRow.append(performanceBtn)

    const allProfileBtns = [
        { btn: powerSaverBtn,  profile: "power-saver"  },
        { btn: balancedBtn,    profile: "balanced"      },
        { btn: performanceBtn, profile: "performance"   },
    ] as const

    const updateProfileBtns = (active: string) => {
        allProfileBtns.forEach(({ btn, profile }) => {
            btn.css_classes = profile === active
                ? ["btn", "btn--outlined", "btn--warn-active"]
                : ["btn", "btn--outlined"]
        })
    }

    allProfileBtns.forEach(({ btn, profile }) => {
        btn.connect("clicked", () => {
            setProfile(profile)
            updateProfileBtns(profile)
        })
    })

    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // FOOTER =================================================
    const footer = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 4 })
    content.append(footer)

    const footerSpacer = new Gtk.Box({ hexpand: true })
    footer.append(footerSpacer)

    const settingsBtn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"], halign: Gtk.Align.END })
    settingsBtn.set_child(new Gtk.Image({ icon_name: "preferences-system-symbolic" }))
    footer.append(settingsBtn)

    // FUNCTIONALITY ==========================================
    const update = () => {
        batteryIcon.icon_name  = battery.batteryIconName ?? "battery-symbolic"
        percentLabel.label     = `${Math.round(battery.percentage * 100)}%`
        stateLabel.label       = battery.charging ? "Charging" : "Discharging"
        batteryBar.fraction    = battery.percentage

        const seconds = battery.charging ? battery.timeToFull : battery.timeToEmpty
        timeLabel.label = seconds > 0
            ? battery.charging ? `Full in ${formatTime(seconds)}` : `${formatTime(seconds)} remaining`
            : ""

        energyLabel.label = battery.energyFull > 0 ? `${battery.energy.toFixed(1)} / ${battery.energyFull.toFixed(1)} Wh` : ""
        rateLabel.label   = battery.energyRate > 0 ? `${battery.energyRate.toFixed(1)} W` : ""

        voltageRow.v.label  = battery.voltage > 0 ? `${battery.voltage.toFixed(2)} V` : "—"
        capacityRow.v.label = battery.capacity > 0 ? `${Math.round(battery.capacity * 100)}%` : "—"

        const hasTemp = battery.temperature > 0
        tempRow.row.set_visible(hasTemp)
        tempRow.v.label = hasTemp ? `${battery.temperature.toFixed(1)} °C` : ""

        const hasWarning = battery.warningLevel !== AstalBattery.WarningLevel.NONE
            && battery.warningLevel !== AstalBattery.WarningLevel.UNKNOWN
        warningRow.row.set_visible(hasWarning)
        warningRow.v.label = warningNames[battery.warningLevel] ?? "—"

        const hasBatteryLevel = battery.batteryLevel !== AstalBattery.BatteryLevel.NONE
            && battery.batteryLevel !== AstalBattery.BatteryLevel.UNKNOWN
        batteryLvlRow.row.set_visible(hasBatteryLevel)
        batteryLvlRow.v.label = batteryLevelNames[battery.batteryLevel] ?? "—"

        presentRow.v.label    = battery.isPresent ? "Yes" : "No"
        onlineRow.v.label     = battery.online ? "Yes" : "No"
        updateTimeRow.v.label = battery.updateTime > 0
            ? new Date(battery.updateTime * 1000).toLocaleTimeString()
            : "—"
    }

    battery.connect("notify::percentage",    update)
    battery.connect("notify::charging",      update)
    battery.connect("notify::energy",        update)
    battery.connect("notify::time-to-empty", update)
    battery.connect("notify::time-to-full",  update)
    battery.connect("notify::energy-rate",   update)
    battery.connect("notify::voltage",       update)
    battery.connect("notify::warning-level", update)
    battery.connect("notify::battery-level", update)
    battery.connect("notify::is-present",    update)
    battery.connect("notify::online",        update)
    battery.connect("notify::update-time",   update)
    battery.connect("notify::temperature",   update)

    popover.connect("notify::visible", () => {
        if (popover.visible) {
            revealer.reveal_child = true
            update()
            updateProfileBtns(getCurrentProfile())
        } else {
            revealer.reveal_child = false
        }
    })

    return popover
}
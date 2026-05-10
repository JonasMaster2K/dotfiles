import { Gtk } from "ags/gtk4"
import Usage from "../../services/SystemInfoService"
import TaskBarIconButton from "../../components/BarButton"

const usage = Usage.get_default()

const bytesToGB = (bytes: number) => (bytes / 1073741824).toFixed(1)

const formatNet = (bytes: number) => {
    if (bytes > 1000000) return `${(bytes / 1000000).toFixed(1)}MB/s`
    if (bytes > 1000) return `${(bytes / 1000).toFixed(0)}KB/s`
    return `${bytes}B/s`
}

function createStat(iconName: string): [Gtk.Box, Gtk.Label] {
    const box = new Gtk.Box({ 
        spacing: 4, 
        valign: Gtk.Align.CENTER 
    })
    
    const icon = new Gtk.Image({ 
        icon_name: iconName, 
        pixel_size: 14,
        css_classes: ["icon--secondary"] 
    })
    
    const label = new Gtk.Label({ 
        css_classes: ["label--meta"],
        valign: Gtk.Align.CENTER 
    })

    box.append(icon)
    box.append(label)
    
    return [box, label]
}

export default function SysInfoWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({ iconName: "computer-symbolic" })

    const wrapper = new Gtk.Box({ visible: false })
    const revealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_RIGHT,
        reveal_child: false,
        valign: Gtk.Align.CENTER,
    })
    
    const statsContainer = new Gtk.Box({ 
        spacing: 12, 
        hexpand: true 
    })

    const [netRxBox, netRxLabel] = createStat("network-receive-symbolic")
    const [netTxBox, netTxLabel] = createStat("network-transmit-symbolic")
    const [cpuBox, cpuLabel]     = createStat("cpu-symbolic")
    const [tempBox, tempLabel]   = createStat("sensors-temperature-symbolic")
    const [memBox, memLabel]     = createStat("ram-symbolic")

    const allBoxes: Gtk.Box[] = [netRxBox, netTxBox, cpuBox, tempBox, memBox]
    allBoxes.forEach(box => statsContainer.append(box))
    
    revealer.set_child(statsContainer)
    wrapper.append(revealer)
    btn.content.append(wrapper)

    const updateMem = () => {
        const used = usage.memoryTotal - usage.memoryAvailable
        memLabel.label = `${bytesToGB(used)}/${bytesToGB(usage.memoryTotal)}GB`
    }

    const updateAll = () => {
        netRxLabel.label = formatNet(usage.netRx)
        netTxLabel.label = formatNet(usage.netTx)
        cpuLabel.label   = `${Math.round(usage.cpuUsage * 100)}%`
        tempLabel.label  = usage.cpuTemp > 0 ? `${usage.cpuTemp}°C` : `--°C`
        updateMem()
    }

    usage.connect("notify::net-rx",           () => { netRxLabel.label = formatNet(usage.netRx) })
    usage.connect("notify::net-tx",           () => { netTxLabel.label = formatNet(usage.netTx) })
    usage.connect("notify::cpu-usage",        () => { cpuLabel.label = `${Math.round(usage.cpuUsage * 100)}%` })
    usage.connect("notify::cpu-temp",         () => { tempLabel.label = usage.cpuTemp > 0 ? `${usage.cpuTemp}°C` : `--°C` })
    usage.connect("notify::memory-available", () => { updateMem() })

    revealer.connect("notify::child-revealed", () => {
        if (!revealer.reveal_child && !revealer.child_revealed) {
            wrapper.visible = false
        }
    })

    btn.connect("clicked", () => {
        if (!revealer.reveal_child) {
            updateAll()
            wrapper.visible = true
            revealer.reveal_child = true
        } else {
            revealer.reveal_child = false
        }
    })

    updateAll()

    return btn as Gtk.Widget
}
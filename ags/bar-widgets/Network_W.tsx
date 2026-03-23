import { Gtk } from "ags/gtk4"
import AstalNetwork from "gi://AstalNetwork"
import NetworkPopup from "../popup-menus/Network_Popup"

export default function NetworkWidget(): Gtk.Widget {
    const network = AstalNetwork.get_default()

    // STRUCTURE ==============================================
    const icon = new Gtk.Image({ icon_name: "network-no-route-symbolic" })

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
    })
    btn.set_child(icon)

    const popupMenu = NetworkPopup(network)
    popupMenu.set_parent(btn)

    // FUNCTIONALITY ==========================================
    const rightClick = new Gtk.GestureClick({ button: 3 })
    btn.add_controller(rightClick)

    let wiredHandler: number | null = null
    let wifiIconHandler: number | null = null
    let wifiSsidHandler: number | null = null

    const update = () => {
        if (wiredHandler)   { network.wired.disconnect(wiredHandler);    wiredHandler = null }
        if (wifiIconHandler){ network.wifi.disconnect(wifiIconHandler);  wifiIconHandler = null }
        if (wifiSsidHandler){ network.wifi.disconnect(wifiSsidHandler);  wifiSsidHandler = null }

        btn.tooltip_text = ""

        switch (network.primary) {
            case AstalNetwork.Primary.WIRED:
                icon.icon_name = network.wired.iconName
                wiredHandler = network.wired.connect("notify::icon-name", () => {
                    icon.icon_name = network.wired.iconName
                })
                break
            case AstalNetwork.Primary.WIFI:
                icon.icon_name   = network.wifi.iconName
                btn.tooltip_text = network.wifi.ssid
                wifiIconHandler = network.wifi.connect("notify::icon-name", () => {
                    icon.icon_name = network.wifi.iconName
                })
                wifiSsidHandler = network.wifi.connect("notify::ssid", () => {
                    btn.tooltip_text = network.wifi.ssid
                })
                break
            default:
                icon.icon_name = "network-no-route-symbolic"
        }
    }

    update()
    rightClick.connect("pressed", () => { network.wifi.enabled = !network.wifi.enabled })
    network.connect("notify::primary", update)
    network.wifi.connect("notify::state", update)
    btn.connect("clicked", () => popupMenu.popup())

    return btn
}
// utils/getIconName.ts
import AstalApps from "gi://AstalApps?version=0.1"
import { Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"

const manager = new AstalApps.Apps()

export default function getIconName(appId: string): string {
    const theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default()!)
    const id = appId.toLowerCase()
    const apps = manager.get_list()

    const candidates = [
        apps.find((a: AstalApps.Application) => a.wm_class?.toLowerCase() === id)?.iconName,
        apps.find((a: AstalApps.Application) => a.entry?.toLowerCase().replace(".desktop", "") === id)?.iconName,
        apps.find((a: AstalApps.Application) => a.name?.toLowerCase() === id)?.iconName,
        apps.find((a: AstalApps.Application) => a.iconName?.toLowerCase() === id)?.iconName,
        apps.find((a: AstalApps.Application) => a.wm_class?.toLowerCase().includes(id) || id.includes(a.wm_class?.toLowerCase() ?? ""))?.iconName,
        apps.find((a: AstalApps.Application) => a.iconName?.toLowerCase().includes(id) || id.includes(a.iconName?.toLowerCase() ?? ""))?.iconName,
        apps.find((a: AstalApps.Application) => a.name?.toLowerCase().includes(id) || id.includes(a.name?.toLowerCase() ?? ""))?.iconName,
        id,
        `${id}-bin`,
    ].filter(Boolean) as string[]

    for (const name of candidates) {
        if (theme.has_icon(name)) return name
    }

    return "application-x-executable"
}
import { Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"
import GLib from "gi://GLib"

let THEME: string = "nordic"

const DARK_CSS  = `${GLib.get_home_dir()}/dotfiles/ags/style/themes/${THEME}/dark.scss`
const LIGHT_CSS = `${GLib.get_home_dir()}/dotfiles/ags/style/themes/${THEME}/light.scss`

let currentProvider: Gtk.CssProvider | null = null
let isDark = true

export default function ThemeToggleWidget(): Gtk.Widget {
    const icon = new Gtk.Image({
        css_classes: ["theme-toggle__icon"],
        icon_name: "weather-clear-night-symbolic",
        pixel_size: 16,
    })

    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget", "theme-toggle"],
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        tooltip_text: "Toggle theme",
    })
    btn.set_child(icon)

    const applyTheme = (dark: boolean) => {
        const display = Gdk.Display.get_default()!

        if (currentProvider) {
            Gtk.StyleContext.remove_provider_for_display(display, currentProvider)
            currentProvider = null
        }

        const provider = new Gtk.CssProvider()
        provider.load_from_path(dark ? DARK_CSS : LIGHT_CSS)
        Gtk.StyleContext.add_provider_for_display(
            display,
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_USER
        )
        currentProvider = provider
        icon.icon_name = dark ? "weather-clear-night-symbolic" : "weather-clear-symbolic"
    }

    applyTheme(isDark)

    btn.connect("clicked", () => {
        isDark = !isDark
        applyTheme(isDark)
    })

    return btn
}
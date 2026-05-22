import { Gtk } from "ags/gtk4"
import Gdk from "gi://Gdk?version=4.0"
import GLib from "gi://GLib"
import BarButton from "../../components/BarButton"

let THEME: string = "nordic"

const DARK_CSS  = `${GLib.get_home_dir()}/dotfiles/ags/style/themes/${THEME}/dark.scss`
const LIGHT_CSS = `${GLib.get_home_dir()}/dotfiles/ags/style/themes/${THEME}/light.scss`

let currentProvider: Gtk.CssProvider | null = null
let isDark = true

export default function ThemeToggleWidget(): Gtk.Widget {
    const btn = new BarButton({iconName: "dark-mode-symbolic"})

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
        btn.icon.icon_name = dark ? "dark-mode-symbolic" : "light-mode-symbolic"
    }

    applyTheme(isDark)

    btn.connect("clicked", () => {
        isDark = !isDark
        applyTheme(isDark)
    })

    return btn
}
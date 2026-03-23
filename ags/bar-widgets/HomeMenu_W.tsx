import { Gtk } from "ags/gtk4"
import HomeMenuPopup from "../popup-menus/HomeMenu_Popup"

export default function HomeMenuWidget(): Gtk.Widget {
    const btn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
        tooltip_text: "Menu",
    })
    btn.set_child(new Gtk.Image({ icon_name: "user-home-symbolic", pixel_size: 16 }))

    const popover = HomeMenuPopup()
    popover.set_parent(btn)
    btn.connect("clicked", () => popover.popup())

    return btn
}
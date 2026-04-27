import { Gtk } from "ags/gtk4"
import AstalTray from "gi://AstalTray?version=0.1"
import Popup from "../../components/Popup"

const tray = AstalTray.get_default()

export default function SystemTrayPopup(): Gtk.Popover {
    const popup = new Popup({ minWidth: -1, minHeight: -1, header: false, footer: false })

    const update = () => {
        let child = popup.body.get_first_child()
        while (child) {
            popup.body.remove(child)
            child = popup.body.get_first_child()
        }

        const items = tray.get_items()
        const cols = Math.min(4, items.length)
        const grid = new Gtk.Grid({ column_spacing: 4, row_spacing: 4 })

        items.forEach((item, i) => {
            const btn = new Gtk.Button({ css_classes: ["btn", "btn--elevated", "btn--round"] })
            btn.set_child(new Gtk.Image({ gicon: item.gicon, pixel_size: 20 }))

            btn.connect("clicked", () => { item.activate(0, 0); popup.popdown() })

            const rightClick = new Gtk.GestureClick({ button: 3 })
            rightClick.connect("pressed", () => {
                if (!item.menuModel) return
                const menu = Gtk.PopoverMenu.new_from_model(item.menuModel)
                menu.set_parent(btn)
                menu.popup()
            })
            btn.add_controller(rightClick)

            const col = i % cols
            const row = Math.floor(i / cols)
            grid.attach(btn, col, row, 1, 1)
        })

        popup.body.append(grid)
    }

    popup.onOpen = update
    return popup
}
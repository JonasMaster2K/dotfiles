import app from "ags/gtk4/app"
import Gdk from "gi://Gdk?version=4.0"

import PrimaryBar   from "./bars/PrimaryTaskBar"
import SecondaryBar from "./bars/SecondaryTaskBar"
import NotificationPopupFeed from "./features/notification/NotificationPopup"
import { popovers } from "./features/homemenu/HomeMenuWidget"

app.start({
    instanceName: "desktop-shell",
    css: "./style/themes/nordic/dark.scss",
    requestHandler(argv: string[], res: (response: any) => void) {
        const popover = popovers.get(argv[0])
        if (popover) {
            if (popover.is_visible()) {
                popover.popdown()
                } else {
                popover.popup()
            }
            res("ok")
        } else {
            res("unknown: " + argv[0])
        }
    },
    main() {
        NotificationPopupFeed()

        const monitors = Gdk.Display.get_default()!.get_monitors()
        const primary  = monitors.get_item(0) as Gdk.Monitor
        const primaryWin = PrimaryBar(primary)

        for (let i = 1; i < monitors.get_n_items(); i++) {
            SecondaryBar(monitors.get_item(i) as Gdk.Monitor)
        }

        monitors.connect("items-changed", (_: any, pos: number, _removed: number, added: number) => {
            for (let i = pos; i < pos + added; i++) {
                SecondaryBar(monitors.get_item(i) as Gdk.Monitor)
            }
        })

        return primaryWin
    },
})
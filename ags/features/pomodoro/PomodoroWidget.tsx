import { Gtk } from "ags/gtk4"
import BarButton from "../../components/BarButton"
import PomodoroTimer from "../../services/PomodoroTimer"
import PomodoroPopup from "./PomodoroPopup"
import formatTime from "../../utils/formatTime"

const timer: PomodoroTimer = new PomodoroTimer({})

export default function PomodoroWidget(): Gtk.Widget {
    const btn = new BarButton({ iconName: timer.iconName })

    const popup = PomodoroPopup(() => timer)
    popup.set_parent(btn)

    //===============================
    //---------- STRUCTURE ----------
    //===============================
    const label = new Gtk.Label({
        label: formatTime(timer.remaining),
        visible: false,
    })
    btn.content.append(label)

    //===============================
    //-------- FUNCTIONALITY --------
    //===============================
    timer.connect("notify::icon-name", () => {
        timer.phase === "idle" ? btn.cssClasses = ["bar__btn"] : timer.phase === "work" ? btn.cssClasses = ["bar__btn--err"] : btn.cssClasses = ["bar__btn--ok"]
        btn.icon.set_from_icon_name(timer.iconName)
        timer.phase === "idle" ? label.visible = false : label.visible = true
    })
    timer.connect("tick", ()=>{label.label = formatTime(timer.remaining)})

    const rightClick = new Gtk.GestureClick({ button: 3 })
    rightClick.connect("pressed", () => timer.toggle())
    btn.add_controller(rightClick)

    btn.connect("clicked", () => popup.popup())

    return btn
}
import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import CalendarPage from "../homemenu/Calendar"
import TodosPage from "../homemenu/Todos"
import HomeMenuHeader from "../homemenu/Header"
import HomeMenuControls from "../homemenu/Controls"
import HomeMenuQuickstart from "../homemenu/Quickstart"
import HomeMenuFilesystem from "../homemenu/Filesystem"
import HomeMenuNotifications from "../homemenu/Notifications"
import TimerPage from "../homemenu/Timer"
import PomodoroPage from "../homemenu/Pomodoro"
import SysInfoPage from "../homemenu/SysInfo"

export default function HomeMenuPopup(): Gtk.Popover {
    const sep = () => new Gtk.Separator({ css_classes: ["divider"] })

    // TAB BAR ================================================
    const tabBar = new Gtk.Box({
        css_classes: ["tab-bar"],
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 4,
    })

    const makeTab = (label: string, active = false, group?: Gtk.ToggleButton) => new Gtk.ToggleButton({
        css_classes: active ? ["tab-btn", "tab-btn--active"] : ["tab-btn"],
        label,
        active,
        ...(group ? { group } : {}),
    })

    const calendarTab  = makeTab("Calendar",    true)
    const todosTab     = makeTab("Todos",        false, calendarTab)
    const timerTab     = makeTab("Timer",        false, calendarTab)
    const pomodoroTab  = makeTab("Pomodoro",     false, calendarTab)
    const sysInfoTab   = makeTab("System-Info",  false, calendarTab)

    ;[calendarTab, todosTab, timerTab, pomodoroTab, sysInfoTab].forEach(t => tabBar.append(t))

    // TAB STACK ==============================================
    const tabStack = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
        transition_duration: 150,
        hexpand: true,
        vexpand: true,
    })
    tabStack.add_named(CalendarPage(),  "calendar")
    tabStack.add_named(TodosPage(),     "todos")
    tabStack.add_named(TimerPage(),     "timer")
    tabStack.add_named(PomodoroPage(),  "pomodoro")
    tabStack.add_named(SysInfoPage(),   "sysInfo")

    const tabs: [Gtk.ToggleButton, string][] = [
        [calendarTab,  "calendar"],
        [todosTab,     "todos"],
        [timerTab,     "timer"],
        [pomodoroTab,  "pomodoro"],
        [sysInfoTab,   "sysInfo"],
    ]

    tabs.forEach(([tab, name]) => {
        tab.connect("toggled", () => {
            if (!tab.active) return
            tabStack.set_visible_child_name(name)
            tabs.forEach(([t]) => {
                t.css_classes = t === tab ? ["tab-btn", "tab-btn--active"] : ["tab-btn"]
            })
        })
    })

    const tabBox = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
        hexpand: true,
        vexpand: true,
    })
    tabBox.append(tabBar)
    tabBox.append(tabStack)

    // CONTENT ================================================
    const content = new Gtk.Box({
        css_classes: ["popover--panel"],
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 12,
        width_request: 650,
    })

    content.append(HomeMenuHeader())
    content.append(sep())
    content.append(HomeMenuControls())
    content.append(sep())
    content.append(HomeMenuQuickstart())
    content.append(sep())
    content.append(HomeMenuFilesystem())
    content.append(sep())
    content.append(HomeMenuNotifications())
    content.append(sep())
    content.append(tabBox)

    // REVEALER ===============================================
    const revealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_LEFT,
        transition_duration: 200,
        reveal_child: false,
    })
    revealer.set_child(content)

    // POPOVER ================================================
    const popover = new Gtk.Popover({
        css_classes: ["home-menu__popover"],
        has_arrow: false,
        autohide: true,
    })
    popover.set_child(revealer)
    popover.set_offset(0, 10)

    popover.connect("notify::visible", () => {
        if (popover.visible) {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10, () => {
                revealer.reveal_child = true
                return GLib.SOURCE_REMOVE
            })
        } else {
            revealer.reveal_child = false
        }
    })

    return popover
}
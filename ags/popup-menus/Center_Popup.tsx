import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import DashboardTab, { DashboardData } from "../center-tabs/dashboard-tab"

function makeTabBtn(icon: string, label: string, onClick: () => void): Gtk.Button {
    return <Gtk.Button css_classes={["tab-btn"]} hexpand $={(self: Gtk.Button) => self.connect("clicked", onClick)}>
        <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={4} halign={Gtk.Align.CENTER}>
            <Gtk.Image iconName={icon} pixelSize={18}/>
            <Gtk.Label cssClasses={["text--xs"]} label={label}/>
        </Gtk.Box>
    </Gtk.Button> as Gtk.Button
}

export default function CenterPopup(): Gtk.Popover {
    let revealer!: Gtk.Revealer
    let stack!: Gtk.Stack

    const dashboardData: DashboardData = { username: "", hostname: "", layout: "", uptime: "" }
    const dash = DashboardTab()

    const loadSystemInfo = () => Promise.all([
        execAsync("whoami").then(v => dashboardData.username = v.trim()),
        execAsync(["bash", "-c", "hostnamectl | grep 'Static hostname' | awk '{print $3}'"]).then(v => dashboardData.hostname = v.trim()),
        execAsync(["bash", "-c", "localectl | grep 'X11 Layout' | awk '{print $3}'"]).then(v => dashboardData.layout = v.trim().toUpperCase()),
        execAsync("uptime -p").then(v => dashboardData.uptime = v.trim().replace("up ", "")),
    ]).then(() => dash.update(dashboardData))

    const popover = <Gtk.Popover
        has_arrow={false}
        autohide={true}
        width_request={800}
        heightRequest={400}
        css_classes={["audio-popover"]}
        $={(self: Gtk.Popover) => {
            self.set_offset(0, 10)
            self.connect("notify::visible", () => {
                revealer.reveal_child = self.visible
                if (self.visible) loadSystemInfo()
            })
        }}
    >
        <Gtk.Revealer
            $={(self: Gtk.Revealer) => revealer = self}
            transition_type={Gtk.RevealerTransitionType.SLIDE_DOWN}
            transition_duration={200}
            reveal_child={false}
        >
            <Gtk.Box css_classes={["popover--panel"]} orientation={Gtk.Orientation.VERTICAL} hexpand spacing={8}>
                <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={4} cssClasses={["tab-bar"]} hexpand>
                    {makeTabBtn("view-grid-symbolic", "Dashboard", () => stack.set_visible_child_name("dashboard"))}
                    {makeTabBtn("weather-symbolic", "Weather", () => stack.set_visible_child_name("weather"))}
                </Gtk.Box>
                <Gtk.Stack
                    $={(self: Gtk.Stack) => stack = self}
                    transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
                    transitionDuration={200}
                    hexpand
                    vexpand
                >
                    {dash.widget}
                    <Gtk.Box $type="named" name="weather" orientation={Gtk.Orientation.VERTICAL} hexpand/>
                </Gtk.Stack>
            </Gtk.Box>
        </Gtk.Revealer>
    </Gtk.Popover> as Gtk.Popover

    return popover
}
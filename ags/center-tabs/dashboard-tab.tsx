import { Gtk } from "ags/gtk4"

export interface DashboardData {
    username: string
    hostname: string
    layout: string
    uptime: string
}

export interface DashboardTabHandle {
    widget: Gtk.Box
    update: (data: DashboardData) => void
}

export default function DashboardTab(): DashboardTabHandle {
    let usernameLabel!: Gtk.Label
    let hostnameLabel!: Gtk.Label
    let kernelLabel!: Gtk.Label
    let uptimeLabel!: Gtk.Label

    const widget = <Gtk.Box $type="named" name="dashboard" orientation={Gtk.Orientation.VERTICAL} hexpand spacing={8}>
        <Gtk.Box css_classes={["card"]} orientation={Gtk.Orientation.HORIZONTAL} spacing={12} hexpand>
            <Gtk.Box orientation={Gtk.Orientation.VERTICAL}>
                <Gtk.Box css_classes={["user-avatar"]}>
                    <Gtk.Image icon_name="avatar-default-symbolic" pixelSize={52} valign={Gtk.Align.CENTER}/>
                </Gtk.Box>
                <Gtk.Label $={(self: Gtk.Label) => usernameLabel = self} css_classes={["text--md", "text--bold", "text--primary"]} label="..." halign={Gtk.Align.CENTER}/>
            </Gtk.Box>
            <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={6} valign={Gtk.Align.CENTER} hexpand>
                <Gtk.Label $={(self: Gtk.Label) => hostnameLabel = self} css_classes={["text--sm", "text--secondary"]} label="..." halign={Gtk.Align.START}/>
                <Gtk.Label $={(self: Gtk.Label) => kernelLabel = self}   css_classes={["text--sm", "text--secondary"]} label="..." halign={Gtk.Align.START}/>
                <Gtk.Label $={(self: Gtk.Label) => uptimeLabel = self}   css_classes={["text--sm", "text--secondary"]} label="..." halign={Gtk.Align.START}/>
            </Gtk.Box>
        </Gtk.Box>
    </Gtk.Box> as Gtk.Box

    const update = (data: DashboardData) => {
        usernameLabel.label = data.username
        hostnameLabel.label = data.hostname
        kernelLabel.label   = data.layout
        uptimeLabel.label   = data.uptime
    }

    return { widget, update }
}
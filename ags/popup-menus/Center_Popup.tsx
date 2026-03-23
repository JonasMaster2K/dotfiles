import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import Usage from "../services/SystemInfoService"

const weatherCodeToIcon: Record<number, string> = {
    113: "weather-clear",
    116: "weather-few-clouds-symbolic",
    119: "weather-overcast-symbolic",
    122: "weather-overcast-symbolic",
    143: "weather-fog-symbolic",
    248: "weather-fog-symbolic",
    260: "weather-fog-symbolic",
    176: "weather-showers-scattered-symbolic",
    263: "weather-showers-scattered-symbolic",
    266: "weather-showers-scattered-symbolic",
    293: "weather-showers-scattered-symbolic",
    296: "weather-showers-scattered-symbolic",
    299: "weather-showers-symbolic",
    302: "weather-showers-symbolic",
    305: "weather-showers-symbolic",
    308: "weather-showers-symbolic",
    353: "weather-showers-symbolic",
    356: "weather-showers-symbolic",
    182: "weather-showers-scattered-symbolic",
    185: "weather-showers-scattered-symbolic",
    281: "weather-showers-scattered-symbolic",
    284: "weather-showers-scattered-symbolic",
    311: "weather-showers-scattered-symbolic",
    314: "weather-showers-scattered-symbolic",
    317: "weather-showers-scattered-symbolic",
    320: "weather-showers-scattered-symbolic",
    179: "weather-snow-symbolic",
    323: "weather-snow-symbolic",
    326: "weather-snow-symbolic",
    329: "weather-snow-symbolic",
    332: "weather-snow-symbolic",
    335: "weather-snow-symbolic",
    338: "weather-snow-symbolic",
    350: "weather-snow-symbolic",
    359: "weather-snow-symbolic",
    362: "weather-snow-symbolic",
    365: "weather-snow-symbolic",
    368: "weather-snow-symbolic",
    371: "weather-snow-symbolic",
    374: "weather-snow-symbolic",
    377: "weather-snow-symbolic",
    200: "weather-storm-symbolic",
    386: "weather-storm-symbolic",
    389: "weather-storm-symbolic",
    392: "weather-storm-symbolic",
    395: "weather-storm-symbolic",
}

const getWeatherIcon = (code: number, isNight = false): string => {
    if (isNight) {
        if (code === 113) return "weather-clear-night-symbolic"
        if (code === 116) return "weather-few-clouds-night-symbolic"
    }
    return weatherCodeToIcon[code] ?? "weather-overcast-symbolic"
}

const usage = Usage.get_default()

export default function CenterPopup(): Gtk.Popover {
    let revealer!: Gtk.Revealer
    let weatherIcon!: Gtk.Image
    let temperatureLabel!: Gtk.Label
    let weatherNameLabel!: Gtk.Label
    let usernameLabel!: Gtk.Label
    let hostnameLabel!: Gtk.Label
    let kernelLabel!: Gtk.Label
    let uptimeLabel!: Gtk.Label
    let memProgressBar!: Gtk.ProgressBar
    let cpuProgressBar!: Gtk.ProgressBar
    let diskSpaceProgressBar!: Gtk.ProgressBar

    const loadSystemInfo = () => {
        execAsync("whoami").then((v) => usernameLabel.label = v.trim())
        execAsync(["bash", "-c", "hostnamectl | grep 'Static hostname' | awk '{print $3}'"]).then((v) => hostnameLabel.label = v.trim())
        execAsync(["bash", "-c", "localectl | grep 'X11 Layout' | awk '{print $3}'"]).then((v) => kernelLabel.label = v.trim().toUpperCase())
        execAsync("uptime -p").then((v) => uptimeLabel.label = v.trim().replace("up ", ""))
    }

    const loadWeather = () => {
        execAsync(`curl -s "ipapi.co/json"`)
            .then((raw) => {
                const city = JSON.parse(raw).city ?? "Bergneustadt"
                return execAsync(`curl -s "wttr.in/${city}?format=j1"`)
            })
            .then((raw) => {
                const current = JSON.parse(raw).current_condition[0]
                const code = parseInt(current.weatherCode)
                const temp = current.temp_C
                const desc = current.weatherDesc[0].value
                const isNight = GLib.DateTime.new_now_local().get_hour() < 6 || GLib.DateTime.new_now_local().get_hour() > 21

                weatherIcon.icon_name = getWeatherIcon(code, isNight)
                temperatureLabel.label = `${temp}°C`
                weatherNameLabel.label = desc
            })
            .catch(() => {
                temperatureLabel.label = "N/A"
                weatherNameLabel.label = "Unavailable"
            })
    }

    const updateMem = () => {
        memProgressBar.fraction = usage.memoryPercent        
    }
    const updateCPU = () => {
        cpuProgressBar.fraction = usage.cpuUsage      
    }
    const updateDiskSpace = () => {
        diskSpaceProgressBar.fraction = usage.diskPercent
    }

    // Refresh uptime every minute
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 60000, () => {
        execAsync("uptime -p").then((v) => uptimeLabel.label = v.trim().replace("up ", ""))
        return GLib.SOURCE_CONTINUE
    })

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
                if (self.visible) {
                    loadSystemInfo()
                }
            })
            loadWeather()
            usage.connect("notify::cpu-usage", updateCPU)
            usage.connect("notify::memory-percent", updateMem)
            usage.connect("notify::disk-percent", updateDiskSpace)
        }}
    >
        <Gtk.Revealer
            $={(self: Gtk.Revealer) => revealer = self}
            transition_type={Gtk.RevealerTransitionType.SLIDE_DOWN}
            transition_duration={200}
            reveal_child={false}
        >
            <Gtk.Box
                css_classes={["popover--panel"]}
                orientation={Gtk.Orientation.HORIZONTAL}
                hexpand={true}
                spacing={8}
            >

                {/* Left Column */}
                <Gtk.Box orientation={Gtk.Orientation.VERTICAL} hexpand={true} spacing={8}>

                    {/* Top Row */}
                    <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={8}>

                        {/* Weather Card */}
                        <Gtk.Box
                            css_classes={["card"]}
                            orientation={Gtk.Orientation.HORIZONTAL}
                            spacing={12}
                            width_request={280}
                            valign={Gtk.Align.FILL}
                        >
                            <Gtk.Image
                                $={(self: Gtk.Image) => weatherIcon = self}
                                icon_name={getWeatherIcon(113)}
                                pixel_size={48}
                                valign={Gtk.Align.CENTER}
                                halign={Gtk.Align.CENTER}
                            />
                            <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={4} valign={Gtk.Align.CENTER}>
                                <Gtk.Label
                                    $={(self: Gtk.Label) => temperatureLabel = self}
                                    css_classes={["text--xl", "text--bold", "text--primary"]}
                                    label="--°C"
                                    halign={Gtk.Align.START}
                                />
                                <Gtk.Label
                                    $={(self: Gtk.Label) => weatherNameLabel = self}
                                    css_classes={["text--sm", "text--secondary"]}
                                    label="Loading..."
                                    halign={Gtk.Align.START}
                                />
                            </Gtk.Box>
                        </Gtk.Box>

                        {/* User Card */}
                        <Gtk.Box
                            css_classes={["card"]}
                            orientation={Gtk.Orientation.HORIZONTAL}
                            spacing={12}
                            hexpand={true}
                        >
                            {/* Avatar */}
                            <Gtk.Box
                                orientation={Gtk.Orientation.VERTICAL}
                                spacing={6}
                            >
                                <Gtk.Box
                                    css_classes={["user-avatar"]}
                                >
                                    <Gtk.Image
                                        icon_name={"avatar-default-symbolic"}
                                        pixelSize={52}
                                        valign={Gtk.Align.CENTER}
                                    />
                                </Gtk.Box>
                                <Gtk.Label
                                    $={(self: Gtk.Label) => usernameLabel = self}
                                    css_classes={["text--md", "text--bold", "text--primary"]}
                                    halign={Gtk.Align.CENTER}
                                    label="..."
                                />
                            </Gtk.Box>

                            {/* Info */}
                            <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={6} valign={Gtk.Align.CENTER} hexpand={true}>
                                <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={6} valign={Gtk.Align.CENTER}>
                                    <Gtk.Image icon_name={"start-here-archlinux"} pixel_size={14} css_classes={["icon--secondary"]}/>
                                    <Gtk.Label css_classes={["text--sm", "text--secondary"]} label={"Arch Linux"} halign={Gtk.Align.START}/>
                                </Gtk.Box>
                                <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={6} valign={Gtk.Align.CENTER}>
                                    <Gtk.Image icon_name={"computer-symbolic"} pixel_size={14} css_classes={["icon--secondary"]}/>
                                    <Gtk.Label
                                        $={(self: Gtk.Label) => hostnameLabel = self}
                                        css_classes={["text--sm", "text--secondary"]}
                                        label={"..."}
                                        halign={Gtk.Align.START}
                                    />
                                </Gtk.Box>
                                <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={6} valign={Gtk.Align.CENTER}>
                                    <Gtk.Image icon_name={"keyboard-symbolic"} pixel_size={14} css_classes={["icon--secondary"]}/>
                                    <Gtk.Label
                                        $={(self: Gtk.Label) => kernelLabel = self}
                                        css_classes={["text--sm", "text--secondary"]}
                                        label={"..."}
                                        halign={Gtk.Align.START}
                                    />
                                </Gtk.Box>
                                <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={6} valign={Gtk.Align.CENTER}>
                                    <Gtk.Image icon_name={"clock-symbolic"} pixel_size={14} css_classes={["icon--primary"]}/>
                                    <Gtk.Label
                                        $={(self: Gtk.Label) => uptimeLabel = self}
                                        css_classes={["text--sm", "text--secondary"]}
                                        label={"..."}
                                        halign={Gtk.Align.START}
                                    />
                                </Gtk.Box>
                            </Gtk.Box>
                        </Gtk.Box>

                    </Gtk.Box>

                    {/* Bottom Row */}
                    <Gtk.Box orientation={Gtk.Orientation.HORIZONTAL} spacing={8}>
                        <Gtk.Box css_classes={["card"]} orientation={Gtk.Orientation.VERTICAL} vexpand widthRequest={128}>

                        </Gtk.Box>
                        <Gtk.Calendar cssClasses={["home-menu__cal"]} widthRequest={384}/>
                        <Gtk.Box css_classes={["card"]} orientation={Gtk.Orientation.HORIZONTAL} vexpand widthRequest={128} spacing={12}>
                            <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={4} hexpand>
                                <Gtk.ProgressBar 
                                    css_classes={["battery-bar"]} 
                                    vexpand 
                                    orientation={Gtk.Orientation.VERTICAL}
                                    inverted
                                    $={(self: Gtk.ProgressBar) => {cpuProgressBar = self}}
                                />
                                <Gtk.Image icon_name={"cpu-symbolic"} pixel_size={14} css_classes={["icon--secondary"]} halign={Gtk.Align.CENTER} valign={Gtk.Align.END} />
                            </Gtk.Box>
                            <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={4} hexpand>
                                <Gtk.ProgressBar 
                                    css_classes={["battery-bar"]} 
                                    vexpand 
                                    orientation={Gtk.Orientation.VERTICAL}
                                    inverted
                                    $={(self: Gtk.ProgressBar)=>{memProgressBar = self}}
                                />
                                <Gtk.Image icon_name={"memory-symbolic"} pixel_size={14} css_classes={["icon--secondary"]} halign={Gtk.Align.CENTER } valign={Gtk.Align.END} />
                            </Gtk.Box>
                            <Gtk.Box orientation={Gtk.Orientation.VERTICAL} spacing={4} hexpand>
                                <Gtk.ProgressBar 
                                    css_classes={["battery-bar"]} 
                                    vexpand 
                                    orientation={Gtk.Orientation.VERTICAL}
                                    inverted
                                    $={(self: Gtk.ProgressBar)=>{diskSpaceProgressBar = self}}
                                />
                                <Gtk.Image icon_name={"drive-symbolic"} pixel_size={14} css_classes={["icon--secondary"]} halign={Gtk.Align.CENTER} valign={Gtk.Align.END} />
                            </Gtk.Box>
                        </Gtk.Box>
                    </Gtk.Box>

                </Gtk.Box>

                {/* Right Column */}
                <Gtk.Box
                    css_classes={["card"]}
                    orientation={Gtk.Orientation.VERTICAL}
                    spacing={8}
                    width_request={160}
                />

            </Gtk.Box>
        </Gtk.Revealer>
    </Gtk.Popover> as Gtk.Popover

    return popover
}
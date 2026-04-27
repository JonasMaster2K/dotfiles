import { Gtk } from "ags/gtk4"
import AstalWp from "gi://AstalWp"
import Pango from "gi://Pango?version=1.0"
import { execAsync } from "ags/process"
import getIconName from "../../utils/getIconName"

function updateMuteButton(btn: Gtk.Button, muted: boolean, muteIcon: string, unmuteIcon: string) {
    btn.icon_name = muted ? muteIcon : unmuteIcon
    btn.css_classes = muted ? ["btn", "btn--outlined", "btn--warn-active"] : ["btn", "btn--outlined"]
}

export default function AudioPopup(audio: AstalWp.Audio): Gtk.Popover {
    const popover = new Gtk.Popover({
        has_arrow: false,
        autohide: true,
        width_request: 400,
        css_classes: ["audio-popover"],
    })
    popover.set_offset(0, 10)

    const revealer = new Gtk.Revealer({
        transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
        transition_duration: 200,
        reveal_child: false,
    })
    popover.set_child(revealer)

    const content = new Gtk.Box({
        css_classes: ["popover--panel"],
        orientation: Gtk.Orientation.VERTICAL,
        hexpand: true,
        spacing: 8,
    })
    revealer.set_child(content)

    // HEADER =================================================
    const headerRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(headerRow)

    const headerLabel = new Gtk.Label({
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        label: "Audio",
    })
    headerRow.append(headerLabel)
    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // SPEAKER SECTION ========================================
    const makeDropdown = () => {
        const model = new Gtk.StringList()
        const factory = new Gtk.SignalListItemFactory()
        const listFactory = new Gtk.SignalListItemFactory()
        const makeFactory = (f: Gtk.SignalListItemFactory) => {
            f.connect("setup", (_, item) => {
                (item as Gtk.ListItem).set_child(new Gtk.Label({
                    wrap: true,
                    wrapMode: Pango.WrapMode.WORD,
                    max_width_chars: 45,
                    css_classes: ["label--mono-sm"],
                }))
            })
            f.connect("bind", (_, item) => {
                const listItem = item as Gtk.ListItem
                const label = listItem.get_child() as Gtk.Label
                label.set_label((model.get_item(listItem.get_position()) as Gtk.StringObject).get_string())
            })
        }
        makeFactory(factory)
        makeFactory(listFactory)
        const dropdown = new Gtk.DropDown({
            model, factory, list_factory: listFactory,
            hexpand: true,
            css_classes: ["audio-dropdown"],
        })
        return { dropdown, model }
    }

    const { dropdown: speakerDropdown, model: speakerModel } = makeDropdown()
    content.append(speakerDropdown)

    const speakerControls = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(speakerControls)

    const muteBtn = new Gtk.Button({ css_classes: ["btn", "btn--outlined"] })
    speakerControls.append(muteBtn)

    const volumeSlider = new Gtk.Scale({
        orientation: Gtk.Orientation.HORIZONTAL,
        adjustment: new Gtk.Adjustment({ lower: 0, upper: 1, step_increment: 0.01, page_increment: 0.1 }),
        hexpand: true,
        css_classes: ["scale--default"],
    })
    speakerControls.append(volumeSlider)

    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // MIC SECTION ============================================
    const micSectionLabel = new Gtk.Label({
        css_classes: ["label--section"],
        halign: Gtk.Align.START,
        label: "Microphone",
    })
    content.append(micSectionLabel)

    const { dropdown: micDropdown, model: micModel } = makeDropdown()
    content.append(micDropdown)

    const micControls = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
    content.append(micControls)

    const micMuteBtn = new Gtk.Button({ css_classes: ["btn", "btn--outlined"] })
    micControls.append(micMuteBtn)

    const micSlider = new Gtk.Scale({
        orientation: Gtk.Orientation.HORIZONTAL,
        adjustment: new Gtk.Adjustment({ lower: 0, upper: 1, step_increment: 0.01, page_increment: 0.1 }),
        hexpand: true,
        css_classes: ["scale--default"],
    })
    micControls.append(micSlider)

    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    // STREAMS ================================================
    const streamSectionLabel = new Gtk.Label({
        css_classes: ["label--section"],
        halign: Gtk.Align.START,
        label: "Applications",
    })
    content.append(streamSectionLabel)

    const streamList = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        hexpand: true,
        spacing: 6,
    })
    content.append(streamList)

    const makeStreamCard = (stream: any) => {
        const card = new Gtk.Box({
            css_classes: ["card"],
            orientation: Gtk.Orientation.VERTICAL,
            hexpand: true,
            spacing: 6,
            margin_top: 2,
            margin_bottom: 2,
        })

        const headerRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
        card.append(headerRow)

        const appIcon = new Gtk.Image({
            icon_name: getIconName(stream.description ?? stream.name ?? ""),
            valign: Gtk.Align.CENTER,
        })
        headerRow.append(appIcon)

        const nameLabel = new Gtk.Label({
            label: stream.description ?? stream.name ?? "Unknown",
            halign: Gtk.Align.START,
            hexpand: true,
            ellipsize: Pango.EllipsizeMode.END,
            max_width_chars: 35,
            css_classes: ["label--subtitle"],
        })
        headerRow.append(nameLabel)

        const controlRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 8 })
        card.append(controlRow)

        const streamMuteBtn = new Gtk.Button()
        updateMuteButton(streamMuteBtn, stream.mute, "audio-volume-muted-symbolic", "audio-volume-medium-symbolic")
        controlRow.append(streamMuteBtn)

        const slider = new Gtk.Scale({
            orientation: Gtk.Orientation.HORIZONTAL,
            adjustment: new Gtk.Adjustment({ lower: 0, upper: 1, step_increment: 0.01, page_increment: 0.1, value: stream.volume }),
            hexpand: true,
            css_classes: ["scale--default"],
        })
        controlRow.append(slider)

        streamMuteBtn.connect("clicked", () => {
            stream.mute = !stream.mute
            updateMuteButton(streamMuteBtn, stream.mute, "audio-volume-muted-symbolic", "audio-volume-medium-symbolic")
        })
        slider.connect("value-changed", () => stream.set_volume(slider.get_value()))
        stream.connect("notify::volume", () => slider.set_value(stream.volume))
        stream.connect("notify::mute", () => updateMuteButton(streamMuteBtn, stream.mute, "audio-volume-muted-symbolic", "audio-volume-medium-symbolic"))

        return card
    }

    const updateStreams = () => {
        while (streamList.get_first_child()) streamList.remove(streamList.get_first_child()!)
        if (audio.streams.length === 0) {
            streamList.append(new Gtk.Label({
                label: "No active streams",
                css_classes: ["label--meta"],
                halign: Gtk.Align.CENTER,
            }))
            return
        }
        audio.streams.forEach((s: any) => streamList.append(makeStreamCard(s)))
    }

    // FOOTER =================================================
    content.append(new Gtk.Separator({ css_classes: ["divider"] }))

    const footer = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, spacing: 4 })
    content.append(footer)

    const footerSpacer = new Gtk.Box({ hexpand: true })
    footer.append(footerSpacer)

    const settingsBtn = new Gtk.Button({
        css_classes: ["btn", "btn--elevated", "btn--round"],
        halign: Gtk.Align.END,
    })
    settingsBtn.set_child(new Gtk.Image({ icon_name: "preferences-system-symbolic" }))
    footer.append(settingsBtn)
    settingsBtn.connect("clicked", () => execAsync(["pavucontrol"]).catch(console.error))

    // FUNCTIONALITY ==========================================
    let speakers: any[] = []
    let mics: any[] = []

    const updateSpeakers = () => {
        speakerModel.splice(0, speakerModel.get_n_items(), [])
        speakers = []
        audio.speakers.forEach((s: any) => { speakerModel.append(s.description); speakers.push(s) })
        const index = speakers.indexOf(audio.defaultSpeaker)
        if (index >= 0) speakerDropdown.set_selected(index)
    }

    const updateMics = () => {
        micModel.splice(0, micModel.get_n_items(), [])
        mics = []
        audio.microphones.forEach((m: any) => { micModel.append(m.description); mics.push(m) })
        const index = mics.indexOf(audio.defaultMicrophone)
        if (index >= 0) micDropdown.set_selected(index)
    }

    const setupSpeaker = () => {
        const speaker = audio.defaultSpeaker
        if (!speaker) return
        volumeSlider.set_value(speaker.volume)
        updateMuteButton(muteBtn, speaker.mute, "audio-volume-muted-symbolic", "audio-volume-medium-symbolic")
        speaker.connect("notify::volume", () => volumeSlider.set_value(speaker.volume))
        speaker.connect("notify::mute", () => updateMuteButton(muteBtn, speaker.mute, "audio-volume-muted-symbolic", "audio-volume-medium-symbolic"))
    }

    const setupMic = () => {
        const mic = audio.defaultMicrophone
        if (!mic) return
        micSlider.set_value(mic.volume)
        updateMuteButton(micMuteBtn, mic.mute, "microphone-sensitivity-muted-symbolic", "audio-input-microphone-symbolic")
        mic.connect("notify::volume", () => micSlider.set_value(mic.volume))
        mic.connect("notify::mute", () => updateMuteButton(micMuteBtn, mic.mute, "microphone-sensitivity-muted-symbolic", "audio-input-microphone-symbolic"))
    }

    muteBtn.connect("clicked", () => {
        audio.defaultSpeaker.mute = !audio.defaultSpeaker.mute
        updateMuteButton(muteBtn, audio.defaultSpeaker.mute, "audio-volume-muted-symbolic", "audio-volume-medium-symbolic")
    })
    volumeSlider.connect("value-changed", () => audio.defaultSpeaker?.set_volume(volumeSlider.get_value()))

    micMuteBtn.connect("clicked", () => {
        audio.defaultMicrophone.mute = !audio.defaultMicrophone.mute
        updateMuteButton(micMuteBtn, audio.defaultMicrophone.mute, "microphone-sensitivity-muted-symbolic", "audio-input-microphone-symbolic")
    })
    micSlider.connect("value-changed", () => audio.defaultMicrophone?.set_volume(micSlider.get_value()))

    speakerDropdown.connect("notify::selected", () => {
        const s = speakers[speakerDropdown.get_selected()]
        if (s) s.set_is_default(true)
    })
    micDropdown.connect("notify::selected", () => {
        const m = mics[micDropdown.get_selected()]
        if (m) m.set_is_default(true)
    })

    audio.connect("notify::speakers", updateSpeakers)
    audio.connect("notify::default-speaker", () => { updateSpeakers(); setupSpeaker() })
    audio.connect("notify::microphones", updateMics)
    audio.connect("notify::default-microphone", () => { updateMics(); setupMic() })
    audio.connect("notify::streams", updateStreams)

    popover.connect("notify::visible", () => {
        if (popover.visible) {
            revealer.reveal_child = true
            updateSpeakers()
            updateMics()
            updateStreams()
            setupSpeaker()
            setupMic()
        } else {
            revealer.reveal_child = false
        }
    })

    return popover
}
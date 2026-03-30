import { Gtk } from "ags/gtk4"
import AstalWp from "gi://AstalWp"
import TaskBarIconButton from "../components/TaskBarIconButton"
import AudioPopup from "../popup-menus/Audio_Popup"

export default function AudioWidget(): Gtk.Widget {
    const wp = AstalWp.get_default()
    const audio = wp.audio
    let speaker = audio.defaultSpeaker

    const btn = new TaskBarIconButton(speaker?.volumeIcon ?? "audio-volume-medium-symbolic")

    const popover = AudioPopup(audio)
    popover.set_parent(btn)

    const rightClick = new Gtk.GestureClick()
    rightClick.set_button(3)
    rightClick.connect("pressed", () => {
        audio.defaultSpeaker.mute = !audio.defaultSpeaker.mute
    })
    btn.add_controller(rightClick)

    const scroll = new Gtk.EventControllerScroll()
    scroll.set_flags(Gtk.EventControllerScrollFlags.VERTICAL)
    scroll.connect("scroll", (_, _dx, dy) => {
        if (!speaker) return
        speaker.volume = Math.max(0, Math.min(1, speaker.volume + dy * 0.02))
    })
    btn.add_controller(scroll)

    const update = () => {
        speaker = audio.defaultSpeaker
        btn.icon.icon_name   = speaker?.volumeIcon ?? "audio-volume-muted-symbolic"
        btn.tooltip_text = Math.round((speaker?.volume ?? 0) * 100) + "%"
    }
    update()
    audio.connect("notify::default-speaker", update)
    speaker?.connect("notify::volume", update)
    speaker?.connect("notify::mute",   update)

    btn.connect("clicked", () => popover.popup())

    return btn
}
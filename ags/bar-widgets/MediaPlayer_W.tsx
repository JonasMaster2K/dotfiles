import { Gtk } from "ags/gtk4"
import AstalMpris from "gi://AstalMpris?version=0.1"
import GLib from "gi://GLib"
import ProgressCircle from "../components/ProgressCircle"
import MediaPlayerPopup, { loadCover, formatTime } from "../popup-menus/MediaPlayer_Popup"

export default function MediaPlayerWidget(): Gtk.Widget {
    const mpris = AstalMpris.get_default()
    const getSpotify = (): AstalMpris.Player | null =>
        mpris.players.find((p: AstalMpris.Player) => p.busName?.includes("spotify")) ?? null

    // PLAYER BUTTON ==========================================
    const circleOverlay = ProgressCircle()
    const playStatusIcon = new Gtk.Image({ icon_name: "media-playback-start-symbolic", pixel_size: 12 })
    circleOverlay.add_overlay(playStatusIcon)

    const trackLabel = new Gtk.Label({
        css_classes: ["label--meta"],
        ellipsize: 3,
        max_width_chars: 35,
        hexpand: true,
        halign: Gtk.Align.START,
        label: "No media",
    })

    const inner = new Gtk.Box({ spacing: 6, valign: Gtk.Align.CENTER })
    inner.append(circleOverlay)
    inner.append(trackLabel)

    const playerBtn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
    })
    playerBtn.set_child(inner)

    // OPEN SPOTIFY BUTTON ====================================
    const openSpotifyBtn = new Gtk.Button({
        css_classes: ["statusbar-widget"],
        valign: Gtk.Align.CENTER,
        tooltip_text: "Open Spotify",
    })
    openSpotifyBtn.set_child(new Gtk.Image({ icon_name: "spotify", pixel_size: 16 }))

    // POPUP ==================================================
    const { popover, coverImage, popoverTitle, popoverArtist, popoverCircle, playPauseIcon,
            timeCurrentLabel, timeTotalLabel, prevBtn, nextBtn, playPauseBtn } = MediaPlayerPopup(playerBtn)

    // STACK ==================================================
    const wrapper = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.CROSSFADE,
        transition_duration: 200,
        hhomogeneous: false,
        vhomogeneous: false,
    })
    wrapper.add_named(openSpotifyBtn, "open")
    wrapper.add_named(playerBtn, "player")
    wrapper.set_visible_child_name("open")

    // FUNCTIONALITY ==========================================
    let progressTimer: number | null = null

    const stopTimer = () => {
        if (progressTimer !== null) { GLib.source_remove(progressTimer); progressTimer = null }
    }

    const updateProgress = (player: AstalMpris.Player) => {
        const len = player.length
        const pos = player.position
        const fraction = len > 0 ? Math.min(pos / len, 1) : 0
        circleOverlay.fraction = fraction
        popoverCircle.fraction = fraction
        timeCurrentLabel.label = formatTime(pos)
        timeTotalLabel.label   = formatTime(len)
    }

    const update = (player: AstalMpris.Player | null) => {
        if (!player) { wrapper.set_visible_child_name("open"); stopTimer(); return }

        const artist = player.artist ?? ""
        const title  = player.title  ?? ""
        trackLabel.label    = artist && title ? `${artist} • ${title}` : title || artist || "No media"
        popoverTitle.label  = title  || "Unknown"
        popoverArtist.label = artist || "Unknown"

        loadCover(coverImage, player.coverArt ?? null)
        updateProgress(player)

        const playing = player.playbackStatus === AstalMpris.PlaybackStatus.PLAYING
        playStatusIcon.icon_name = playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
        playPauseIcon.icon_name  = playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"

        wrapper.set_visible_child_name("player")

        if (playing && progressTimer === null) {
            progressTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
                const p = getSpotify()
                if (!p) { progressTimer = null; return GLib.SOURCE_REMOVE }
                updateProgress(p)
                return GLib.SOURCE_CONTINUE
            })
        } else if (!playing) {
            stopTimer()
        }
    }

    const connectPlayer = (player: AstalMpris.Player) => {
        player.connect("notify::title",           () => update(player))
        player.connect("notify::artist",          () => update(player))
        player.connect("notify::playback-status", () => update(player))
        player.connect("notify::length",          () => update(player))
        player.connect("notify::cover-art",       () => loadCover(coverImage, player.coverArt ?? null))
        update(player)
    }

    // EVENTS =================================================
    const rightClick = new Gtk.GestureClick({ button: 3 })
    rightClick.connect("pressed", () => getSpotify()?.play_pause())
    playerBtn.add_controller(rightClick)

    playerBtn.connect("clicked", () => popover.popup())
    openSpotifyBtn.connect("clicked", () => GLib.spawn_command_line_async("spotify"))
    prevBtn.connect("clicked", () => getSpotify()?.previous())
    nextBtn.connect("clicked", () => getSpotify()?.next())
    playPauseBtn.connect("clicked", () => getSpotify()?.play_pause())

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
        const existing = getSpotify()
        if (existing) connectPlayer(existing)
        return GLib.SOURCE_REMOVE
    })

    mpris.connect("player-added", (_: any, player: AstalMpris.Player) => {
        if (player.busName?.includes("spotify")) connectPlayer(player)
    })
    mpris.connect("player-closed", (_: any, player: AstalMpris.Player) => {
        if (player.busName?.includes("spotify")) { stopTimer(); wrapper.set_visible_child_name("open") }
    })

    return wrapper
}
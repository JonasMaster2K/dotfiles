import { Gtk } from "ags/gtk4"
import GdkPixbuf from "gi://GdkPixbuf?version=2.0"
import AstalMpris from "gi://AstalMpris?version=0.1"
import BarButton from "../../components/BarButton"
import Marquee from "../../components/Marquee"
import AudioVisualizer from "../../services/AudioVisualizer"
import MediaPlayerPopup from "./MediaPlayerPopup"

const mpris: AstalMpris.Mpris = AstalMpris.get_default()
const BAR_COUNT  = 12

function cleanText(s: string): string {
    return s.replace(/\s+[\-\(\[\{].*$/, "").trim()
}

export default function MediaPlayerWidget(barHight: number): Gtk.Widget {
    const visualizer = new AudioVisualizer(BAR_COUNT)

    let COVERSIZE: number = barHight - 19

    // ═══════════════════════════════════════
    // STRUCTURE
    // ═══════════════════════════════════════

    const btn = new BarButton({ minWidth: -1 })

    // — Revealer (whole widget) —
    const revealer = new Gtk.Revealer({
        transition_duration: 200,
        transitionType: Gtk.RevealerTransitionType.SWING_RIGHT,
        revealChild: false,
    })
    btn.content.append(revealer)

    const content = new Gtk.Box({ spacing: 0 })
    revealer.set_child(content)

    // — Cover art —
    const coverWrapper = new Gtk.Overlay({
        css_classes: ["media-player__cover"],
        overflow: Gtk.Overflow.HIDDEN,
        valign: Gtk.Align.CENTER,
        width_request: COVERSIZE,
        height_request: COVERSIZE,
        marginEnd: 6,
    })
    const coverArt = new Gtk.Image({
        pixel_size: COVERSIZE,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    })
    coverWrapper.set_child(coverArt)

    const pauseOverlay = new Gtk.Box({
        css_classes: ["media-player__pause-overlay"],
        halign: Gtk.Align.FILL,
        valign: Gtk.Align.FILL,
        visible: false,
    })
    pauseOverlay.append(new Gtk.Image({
        iconName: "media-playback-pause-symbolic",
        pixelSize: 14,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        hexpand: true,
        vexpand: true,
    }))
    coverWrapper.add_overlay(pauseOverlay)
    content.append(coverWrapper)

    // — Center: title + progress —
    const centerBox = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        valign: Gtk.Align.END,
        spacing: 5,
    })
    content.append(centerBox)

    const titleArtistLabel = new Marquee({
        text: "No media  —  No artist",
        gap: 20,
        maxWidth: 210,
        scrollOnTimer: true,
        scrollInterval: 60000,
    })
    titleArtistLabel.hexpand = true
    titleArtistLabel.css_classes = ["label--meta"]
    centerBox.append(titleArtistLabel)

    const progressBar = new Gtk.ProgressBar({
        hexpand: true,
        fraction: 0,
        css_classes: ["media-player__progress"],
    })
    centerBox.append(progressBar)

    // — Visualizer —
    const audioVisualizerRevealer = new Gtk.Revealer({
        transition_duration: 200,
        transitionType: Gtk.RevealerTransitionType.SWING_RIGHT,
        revealChild: false,
        visible: false,
        marginStart: 6,
    })
    content.append(audioVisualizerRevealer)

    const drawingArea = new Gtk.DrawingArea({
        css_classes: ["media-player__visualizer"],
        widthRequest: 75,
        valign: Gtk.Align.FILL,
    })
    audioVisualizerRevealer.set_child(drawingArea)

    // — Popup —
    const popup = MediaPlayerPopup(() => player)
    popup.set_parent(btn)

    // ═══════════════════════════════════════
    // LOGIC
    // ═══════════════════════════════════════

    let player: AstalMpris.Player | null = null
    let playerSignals: number[] = []

    // — Drawing —
    drawingArea.set_draw_func((_area, cr, width, height) => {
        const bars = visualizer.getBars()
        const barW = width / BAR_COUNT
        const gap    = 2
        const radius = 2
        for (let i = 0; i < BAR_COUNT; i++) {
            const h = Math.max(bars[i] * height, 2)
            const x = i * barW + gap / 2
            const y = height - h
            const w = barW - gap
            cr.setSourceRGBA(0.533, 0.753, 0.816, 0.4 + bars[i] * 0.6)
            cr.moveTo(x + radius, y)
            cr.lineTo(x + w - radius, y)
            cr.arc(x + w - radius, y + radius, radius, -Math.PI / 2, 0)
            cr.lineTo(x + w, y + h)
            cr.lineTo(x, y + h)
            cr.arc(x + radius, y + radius, radius, Math.PI, Math.PI * 1.5)
            cr.closePath()
            cr.fill()
        }
    })
    visualizer.subscribe(() => drawingArea.queue_draw())

    audioVisualizerRevealer.connect("notify::child-revealed", () => {
        if (!audioVisualizerRevealer.child_revealed)
            audioVisualizerRevealer.visible = false
    })

    // — Player updates —
    const disconnectPlayer = () => {
        if (!player) return
        playerSignals.forEach(id => player!.disconnect(id))
        playerSignals = []
    }

    const update = () => {
        if (!player) return
        const url = player.coverArt
        if (!url) {
            coverArt.iconName = "audio-x-generic-symbolic"
        } else {
            try {
                coverArt.set_from_pixbuf(
                    GdkPixbuf.Pixbuf.new_from_file_at_scale(url, COVERSIZE, COVERSIZE, true)
                )
            } catch (_) {
                coverArt.iconName = "audio-x-generic-symbolic"
            }
        }
        const title  = cleanText(player.title  ?? "")
        const artist = cleanText(player.artist ?? "")
        titleArtistLabel.text = title
            ? artist ? `${title}  —  ${artist}` : title
            : "No media  —  No artist"
    }

    const updateProgress = () => {
        if (!player) return
        const len = player.length ?? 0
        const pos = player.position ?? 0
        progressBar.fraction = len > 0 ? Math.min(pos / len, 1) : 0
    }

    const updateVisualizer = () => {
        const playing = player?.playbackStatus === AstalMpris.PlaybackStatus.PLAYING
        pauseOverlay.visible = !playing
        if (playing) {
            visualizer.start()
            audioVisualizerRevealer.visible = true
            audioVisualizerRevealer.reveal_child = true
        } else {
            visualizer.stop()
            audioVisualizerRevealer.reveal_child = false
        }
    }

    const setVisible = (visible: boolean) => {
        revealer.reveal_child = visible
        if (!visible) visualizer.stop()
    }

    const bindPlayer = (p: AstalMpris.Player) => {
        disconnectPlayer()
        player = p
        playerSignals = [
            player.connect("notify::title",           update),
            player.connect("notify::artist",          update),
            player.connect("notify::metadata",        update),
            player.connect("notify::cover-art",       update),
            player.connect("notify::position",        updateProgress),
            player.connect("notify::playback-status", () => { updateVisualizer(); update() }),
        ]
        update()
        updateProgress()
        updateVisualizer()
        setVisible(true)
    }

    // — MPRIS connections —
    if (mpris.players[0]) bindPlayer(mpris.players[0])

    mpris.connect("player-added",  (_: any, p: AstalMpris.Player) => bindPlayer(p))
    mpris.connect("player-closed", () => {
        disconnectPlayer()
        player = mpris.players[0] ?? null
        if (player) bindPlayer(player)
        else setVisible(false)
    })

    // — Input —
    const motion = new Gtk.EventControllerMotion()
    motion.connect("enter", () => { titleArtistLabel.scrolling = true })
    motion.connect("leave", () => { titleArtistLabel.scrolling = false })
    btn.add_controller(motion)

    const swipe = new Gtk.GestureSwipe({ n_points: 4, touch_only: false })
    swipe.connect("swipe", (_gesture, vx) => {
        if (!player) return
        if (vx > 300)       player.next()
        else if (vx < -300) player.previous()
    })
    btn.add_controller(swipe)

    const rightClick = new Gtk.GestureClick({ button: 3 })
    rightClick.connect("pressed", () => player?.play_pause())
    btn.add_controller(rightClick)

    btn.connect("clicked",  () => popup.popup())
    btn.connect("destroy",  () => { disconnectPlayer(); visualizer.stop() })

    return btn
}
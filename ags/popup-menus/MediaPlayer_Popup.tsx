import { Gtk } from "ags/gtk4"
import AstalMpris from "gi://AstalMpris?version=0.1"
import GdkPixbuf from "gi://GdkPixbuf"
import ProgressCircle from "../components/ProgressCircle"

export const loadCover = (coverImage: Gtk.Image, url: string | null) => {
    if (!url) { coverImage.icon_name = "spotify"; return }
    try {
        const path = url.startsWith("file://") ? url.replace("file://", "") : url
        const pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 80, 80, true)
        coverImage.set_from_pixbuf(pixbuf)
    } catch {
        coverImage.icon_name = "spotify"
    }
}

export const formatTime = (seconds: number): string => {
    const s = Math.max(0, Math.floor(seconds))
    const m = Math.floor(s / 60)
    return `${m}:${String(s % 60).padStart(2, "0")}`
}

export interface MediaPlayerPopupRefs {
    popover: Gtk.Popover
    coverImage: Gtk.Image
    popoverTitle: Gtk.Label
    popoverArtist: Gtk.Label
    popoverCircle: ReturnType<typeof ProgressCircle>
    playPauseIcon: Gtk.Image
    timeCurrentLabel: Gtk.Label
    timeTotalLabel: Gtk.Label
    prevBtn: Gtk.Button
    nextBtn: Gtk.Button
    playPauseBtn: Gtk.Button
}

export default function MediaPlayerPopup(parentBtn: Gtk.Button): MediaPlayerPopupRefs {
    // COVER ==================================================
    const coverImage = new Gtk.Image({
        css_classes: ["media-cover"],
        pixel_size: 100,
        icon_name: "spotify",
        valign: Gtk.Align.START,
    })

    // TITLE + ARTIST =========================================
    const popoverTitle = new Gtk.Label({
        css_classes: ["label--title"],
        halign: Gtk.Align.START,
        wrap: true,
        wrap_mode: Gtk.WrapMode.WORD,
        max_width_chars: 40,
        label: "",
    })

    const popoverArtist = new Gtk.Label({
        css_classes: ["label--subtitle"],
        halign: Gtk.Align.START,
        ellipsize: 3,
        max_width_chars: 40,
        label: "",
    })

    // CONTROLS ===============================================
    const prevBtn = new Gtk.Button({ css_classes: ["btn"] })
    prevBtn.set_child(new Gtk.Image({ icon_name: "media-skip-backward-symbolic", pixel_size: 18 }))

    const nextBtn = new Gtk.Button({ css_classes: ["btn"] })
    nextBtn.set_child(new Gtk.Image({ icon_name: "media-skip-forward-symbolic", pixel_size: 18 }))

    const skipBox = new Gtk.Box({ spacing: 4, valign: Gtk.Align.CENTER, halign: Gtk.Align.START, hexpand: true })
    skipBox.append(prevBtn)
    skipBox.append(nextBtn)

    const timeCurrentLabel = new Gtk.Label({ css_classes: ["label--meta"], label: "0:00", valign: Gtk.Align.CENTER })
    const timeTotalLabel   = new Gtk.Label({ css_classes: ["label--meta"], label: "0:00", valign: Gtk.Align.CENTER })
    const timeSepLabel     = new Gtk.Label({ css_classes: ["label--meta"], label: "/" })

    const popoverCircle = ProgressCircle(36)
    const playPauseIcon = new Gtk.Image({ icon_name: "media-playback-start-symbolic", pixel_size: 18 })
    popoverCircle.add_overlay(playPauseIcon)

    const playPauseBtn = new Gtk.Button({ css_classes: ["btn", "btn--accent", "btn--round"] })
    playPauseBtn.set_child(popoverCircle)

    const playBox = new Gtk.Box({ spacing: 4, valign: Gtk.Align.CENTER, halign: Gtk.Align.END })
    playBox.append(timeCurrentLabel)
    playBox.append(timeSepLabel)
    playBox.append(timeTotalLabel)
    playBox.append(playPauseBtn)

    const bottomRow = new Gtk.Box({ spacing: 8, valign: Gtk.Align.CENTER, hexpand: true })
    bottomRow.append(skipBox)
    bottomRow.append(playBox)

    // RIGHT COL ==============================================
    const rightCol = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 6,
        hexpand: true,
        valign: Gtk.Align.FILL,
    })
    rightCol.append(popoverTitle)
    rightCol.append(popoverArtist)
    rightCol.append(new Gtk.Box({ vexpand: true }))
    rightCol.append(bottomRow)

    // POPOVER ================================================
    const popoverContent = new Gtk.Box({
        css_classes: ["popover--panel"],
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 12,
        width_request: 450,
    })
    popoverContent.append(coverImage)
    popoverContent.append(rightCol)

    const popover = new Gtk.Popover({
        css_classes: ["media-popover"],
        hasArrow: false,
    })
    popover.set_offset(0, 10)
    popover.set_parent(parentBtn)
    popover.set_child(popoverContent)

    return { popover, coverImage, popoverTitle, popoverArtist, popoverCircle, playPauseIcon, timeCurrentLabel, timeTotalLabel, prevBtn, nextBtn, playPauseBtn }
}
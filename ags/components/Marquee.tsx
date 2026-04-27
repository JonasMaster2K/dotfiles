import GObject from "gi://GObject"
import GLib from "gi://GLib?version=2.0"
import { Gtk, Gdk } from "ags/gtk4"
import Pango from "gi://Pango"
import PangoCairo from "gi://PangoCairo"

export interface ScrollLabelOptions {
    text?: string
    maxWidth?: number
    pxPerSec?: number
    gap?: number
    scrollOnTimer?: boolean
    scrollInterval?: number
}

export class Marquee extends Gtk.DrawingArea {
    static { GObject.registerClass(this) }

    private _text: string = ""
    private _pxPerSec: number = 40
    private _gap: number = 48
    private _maxWidth: number = 200
    private _offset: number = 0
    private _scrolling: boolean = false
    private _textWidth: number = 0
    private _lastTime: number | null = null
    private _layout: any = null

    private _scrollOnTimer: boolean = false
    private _scrollInterval: number = 5000
    private _timerHandle: number | null = null
    private _timerActive: boolean = false
    private _tickId: number | null = null

    constructor(opts: ScrollLabelOptions = {}) {
        super({
            width_request: opts.maxWidth ?? 200,
            height_request: 16,
            halign: Gtk.Align.START,
            valign: Gtk.Align.CENTER,
            hexpand: false,
            vexpand: false,
        })
        this._text           = opts.text           ?? ""
        this._pxPerSec       = opts.pxPerSec       ?? 40
        this._gap            = opts.gap             ?? 48
        this._maxWidth       = opts.maxWidth        ?? 200
        this._scrollOnTimer  = opts.scrollOnTimer   ?? false
        this._scrollInterval = opts.scrollInterval  ?? 5000

        this.set_draw_func(this._draw.bind(this))
        this._tickId = this.add_tick_callback(this._tick.bind(this))

        if (this._scrollOnTimer) this._scheduleNext()

        this.connect("destroy", () => {
            this._clearTimer()
            if (this._tickId !== null) {
                this.remove_tick_callback(this._tickId)
                this._tickId = null
            }
        })
    }

    get text() { return this._text }
    set text(v: string) {
        if (this._text === v) return
        this._text = v
        this._layout = null
        this._offset = 0
        this._lastTime = null
        if (this._scrollOnTimer) {
            this._clearTimer()
            this._timerActive = false
            this._scheduleNext()
        }
        this.queue_draw()
    }

    get speed() { return this._pxPerSec }
    set speed(v: number) { this._pxPerSec = v }

    get gap() { return this._gap }
    set gap(v: number) { this._gap = v }

    get scrolling() { return this._scrolling }
    set scrolling(v: boolean) {
        this._scrolling = v
        if (!v) {
            this._offset = 0
            this._lastTime = null
            if (this._scrollOnTimer && !this._timerActive && this._timerHandle === null) {
                this._scheduleNext()
            }
        }
        this.queue_draw()
    }

    get scrollOnTimer() { return this._scrollOnTimer }
    set scrollOnTimer(v: boolean) {
        this._scrollOnTimer = v
        this._clearTimer()
        this._timerActive = false
        this._offset = 0
        if (v) this._scheduleNext()
    }

    get scrollInterval() { return this._scrollInterval }
    set scrollInterval(v: number) { this._scrollInterval = v }

    private _scheduleNext() {
        this._timerHandle = GLib.timeout_add(GLib.PRIORITY_DEFAULT, this._scrollInterval, () => {
            this._timerActive = true
            this._lastTime = null
            this._timerHandle = null
            return GLib.SOURCE_REMOVE
        })
    }

    private _clearTimer() {
        if (this._timerHandle !== null) {
            GLib.source_remove(this._timerHandle)
            this._timerHandle = null
        }
    }

    private get _active(): boolean {
        if (this._textWidth === 0 || this._textWidth <= this._maxWidth) return false
        return this._scrolling || (this._scrollOnTimer ? this._timerActive : false)
    }

    private _draw(_area: Gtk.DrawingArea, cr: any, _w: number, h: number) {
        const color = this.get_style_context().get_color()

        if (!this._layout) {
            this._layout = PangoCairo.create_layout(cr)
            this._layout.set_text(this._text, -1)
            this._layout.set_font_description(Pango.font_description_from_string("Sans 10"))
        } else {
            PangoCairo.update_layout(cr, this._layout)
        }

        const [, extents] = this._layout.get_pixel_extents()
        this._textWidth = extents.width
        this.height_request = extents.height

        cr.save()
        cr.rectangle(0, 0, this._maxWidth, h)
        cr.clip()

        Gdk.cairo_set_source_rgba(cr, color)

        if (this._active) {
            // scrolling — kein ellipsize, Text läuft durch
            this._layout.set_ellipsize(Pango.EllipsizeMode.NONE)
            cr.moveTo(-this._offset, (h - extents.height) / 2)
            PangoCairo.show_layout(cr, this._layout)
            cr.moveTo(this._textWidth + this._gap - this._offset, (h - extents.height) / 2)
            PangoCairo.show_layout(cr, this._layout)
        } else {
            // nicht scrollend — ellipsize am Ende
            this._layout.set_width(this._maxWidth * Pango.SCALE)
            this._layout.set_ellipsize(Pango.EllipsizeMode.END)
            cr.moveTo(0, (h - extents.height) / 2)
            PangoCairo.show_layout(cr, this._layout)
            // width danach zurücksetzen für textWidth-Messung
            this._layout.set_width(-1)
            this._layout.set_ellipsize(Pango.EllipsizeMode.NONE)
        }

        cr.restore()
    }

    private _tick(_widget: Gtk.Widget, clock: any): boolean {
        if (this._tickId === null) return false

        if (!this._active) {
            this._offset = 0
            this._lastTime = null
            return true
        }

        const now = clock.get_frame_time()
        if (this._lastTime === null) { this._lastTime = now; return true }

        const dtSec = (now - this._lastTime) / 1_000_000
        this._lastTime = now
        const cycle = this._textWidth + this._gap
        const prev = this._offset
        this._offset = (this._offset + this._pxPerSec * dtSec) % cycle

        if (this._scrollOnTimer && !this._scrolling && this._offset < prev) {
            this._timerActive = false
            this._offset = 0
            this._lastTime = null
            this._scheduleNext()
        }

        this.queue_draw()
        return true
    }
}

export default Marquee
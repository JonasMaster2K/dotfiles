import GLib from "gi://GLib?version=2.0"
import Gio from "gi://Gio?version=2.0"
import GObject from "gi://GObject?version=2.0"

export default class AudioVisualizer extends GObject.Object {
    static {
        GObject.registerClass({
            GTypeName: "AudioVisualizer",
            Signals: {
                "started": {},
                "stopped": {},
            },
        }, this)
    }

    private bars: number[]
    private targets: number[]
    private cavaProc: Gio.Subprocess | null = null
    private cavaStream: Gio.DataInputStream | null = null
    private animTimer: number | null = null
    private listeners = new Set<() => void>()
    private readonly barCount: number
    private readonly BAR_RISE = 0.25
    private readonly BAR_FALL = 0.06

    private get config() {
        return `
[general]
bars = ${this.barCount}
framerate = 60
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
`
    }

    constructor(barCount = 20) {
        super()
        this.barCount = barCount
        this.bars     = new Array(barCount).fill(0)
        this.targets  = new Array(barCount).fill(0)
    }

    getBars(): number[] { return this.bars }
    getBarcount(): number { return this.barCount }

    subscribe(cb: () => void): () => void {
        this.listeners.add(cb)
        return () => this.listeners.delete(cb)
    }

    start() {
        if (this.cavaProc) return

        const path = `${GLib.get_tmp_dir()}/ags-cava.conf`
        try {
            Gio.File.new_for_path(path).replace_contents(
                new TextEncoder().encode(this.config),
                null, false,
                Gio.FileCreateFlags.REPLACE_DESTINATION,
                null
            )
        } catch (e) {
            print("[visualizer] config write error:", e)
        }

        try {
            this.cavaProc = Gio.Subprocess.new(
                ["cava", "-p", path],
                Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE
            )
        } catch (e) {
            print("[visualizer] cava not found:", e)
            return
        }

        const stream = new Gio.DataInputStream({
            base_stream: this.cavaProc.get_stdout_pipe()!
        })
        this.cavaStream = stream

        const readLine = () => {
            if (this.cavaStream !== stream) return
            stream.read_line_async(GLib.PRIORITY_LOW, null, (_, res) => {
                if (this.cavaStream !== stream) return
                try {
                    const [line] = stream.read_line_finish_utf8(res)
                    if (line) {
                        this.targets = line.trim().split(";").filter(Boolean)
                            .map(v => Math.min(parseInt(v) / 100, 1))
                    }
                } catch (_) {}
                if (this.cavaStream === stream) readLine()
            })
        }
        readLine()

        this.animTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 16, () => {
            let changed = false
            for (let i = 0; i < this.barCount; i++) {
                const t = this.targets[i] ?? 0
                const c = this.bars[i]
                const speed = t > c ? this.BAR_RISE : this.BAR_FALL
                const next = c + (t - c) * speed
                if (Math.abs(next - c) > 0.001) { this.bars[i] = next; changed = true }
            }
            if (changed) this.listeners.forEach(cb => cb())
            return GLib.SOURCE_CONTINUE
        })

        this.emit("started")
    }

    stop() {
        if (this.animTimer !== null) { GLib.source_remove(this.animTimer); this.animTimer = null }
        const proc = this.cavaProc
        this.cavaProc   = null
        this.cavaStream = null
        try { proc?.force_exit() } catch (_) {}
        this.bars    = new Array(this.barCount).fill(0)
        this.targets = new Array(this.barCount).fill(0)
        this.listeners.forEach(cb => cb())
        this.emit("stopped")
    }
}
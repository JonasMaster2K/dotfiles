import GObject from "gi://GObject?version=2.0"
import GLib from "gi://GLib?version=2.0"

export type PomodoroPhase = "work" | "short-break" | "long-break" | "idle"

export interface PomodoroConfig {
    workDuration?:       number
    shortBreakDuration?: number
    longBreakDuration?:  number
    sessionsUntilLong?:  number
    sessionsPerBlock?:   number
    autoStart?:          boolean
}

export default class PomodoroTimer extends GObject.Object {
    //GObject registration
    static {
        GObject.registerClass({
            GTypeName: "PomodoroTimer",
            Signals: {
                "tick":              {},
                "started":           {},
                "paused":            {},
                "reset":             {},
                "phase-changed":     { param_types: [GObject.TYPE_STRING] },
                "phase-completed":   { param_types: [GObject.TYPE_STRING] },
                "session-completed": {},
                "block-completed":   {},
                "target-reached":    {},
                "config-changed":    {},
            },
            Properties: {
                "running":   GObject.ParamSpec.boolean("running",   "", "", GObject.ParamFlags.READABLE, false),
                "phase":     GObject.ParamSpec.string( "phase",     "", "", GObject.ParamFlags.READABLE, "work"),
                "remaining": GObject.ParamSpec.int(    "remaining", "", "", GObject.ParamFlags.READABLE, 0, 99999, 25 * 60),
                "icon-name": GObject.ParamSpec.string( "icon-name", "", "", GObject.ParamFlags.READABLE, "tomato-symbolic"),
            },
        }, this)
    }

    //Constants
    private readonly defaultSymbol:    string = "com.github.tomatoers.tomato"
    private readonly workSymbol:       string = "appointment-soon"
    private readonly shortBreakSymbol: string = "weather-clear"
    private readonly longBreakSymbol:  string = "go-home"
    private readonly minWorkDuration:  number = 10 * 60
    private readonly maxWorkDuration:  number = 90 * 60
    private readonly minBreakDuration: number =  5 * 60
    private readonly maxBreakDuration: number = 30 * 60

    //State Parameters
    private _running              = false
    private _phase: PomodoroPhase = "idle"
    private _elapsed              = 0
    private _sessionCount         = 0
    private _totalSessions        = 0
    private _sessionsPerBlock       = 0
    private _targetDuration       = 0
    private _blockCount           = 0
    private _timer: number | null = null
    private _waitingForConfirm    = false
    private _iconName             = this.defaultSymbol

    //Configurable Parameters
    private _workDuration:       number
    private _shortBreakDuration: number
    private _longBreakDuration:  number
    private _sessionsUntilLong:  number
    autoStart:                   boolean

    //Constructor
    constructor(config: PomodoroConfig = {}) {
        super()
        this._workDuration       = config.workDuration       ?? 25 * 60
        this._shortBreakDuration = config.shortBreakDuration ??  5 * 60
        this._longBreakDuration  = config.longBreakDuration  ?? 15 * 60
        //if (config.sessionsPerBlock !== undefined) this._sessionsPerBlock = config.sessionsPerBlock
        this._sessionsPerBlock     = config.sessionsPerBlock     ?? 0
        this._sessionsUntilLong  = config.sessionsUntilLong  ?? (this.sessionsPerBlock < 4 && this.sessionsPerBlock > 0 ? this._sessionsPerBlock : 4)
        this.autoStart           = config.autoStart          ?? false
    }

    //Getter
    get running()            { return this._running }
    get phase()              { return this._phase }
    get elapsed()            { return this._elapsed }
    get remaining()          { return this.phaseDuration - this._elapsed }
    get sessions()           { return this._sessionCount }
    get totalSessions()      { return this._totalSessions }
    get blockCount()         { return this._blockCount }
    get waitingForConfirm()  { return this._waitingForConfirm }
    get iconName()           { return this._iconName }
    get sessionsPerBlock()     { return this._sessionsPerBlock }
    get targetDuration()     { return this._targetDuration }
    get workDuration()       { return this._workDuration }
    get shortBreakDuration() { return this._shortBreakDuration }
    get longBreakDuration()  { return this._longBreakDuration }
    get sessionsUntilLong()  { return this._sessionsUntilLong }

    get phaseDuration() {
        if (this._phase === "work")        return this._workDuration
        if (this._phase === "short-break") return this._shortBreakDuration
        if (this._phase === "long-break")  return this._longBreakDuration
        return 0
    }

    get fraction() {
        return Math.min(this._elapsed / this.phaseDuration, 1)
    }

    get blockDuration() {
        const longBreaks     = Math.floor((this._sessionsPerBlock - 1) / this._sessionsUntilLong)
        const shortBreaks    = (this._sessionsPerBlock - 1) - longBreaks
        const shortBreakTime = shortBreaks * this._shortBreakDuration
        const longBreakTime  = longBreaks  * this._longBreakDuration
        return this._sessionsPerBlock * this._workDuration + shortBreakTime + longBreakTime
    }

    //Setter
    set workDuration(v: number) {
        this._workDuration = v
        this.emit("config-changed")
    }

    set shortBreakDuration(v: number) {
        this._shortBreakDuration = v
        this.emit("config-changed")
    }

    set longBreakDuration(v: number) {
        this._longBreakDuration = v
        this.emit("config-changed")
    }

    set sessionsUntilLong(v: number) {
        this._sessionsUntilLong = v
        this.emit("config-changed")
    }

    set sessionsPerBlock(v: number) {
        this._sessionsPerBlock = v
        this.emit("config-changed")
    }

    //Methods
    setDuration(duration: number) {
        const workRatio  = 25 * 60
        const shortRatio =  5 * 60
        const longRatio  = 15 * 60

        const avgBreak = ((this._sessionsUntilLong - 1) * shortRatio + longRatio) / this._sessionsUntilLong
        const avgSlot  = workRatio + avgBreak

        const sessions   = Math.max(1, Math.round(duration / avgSlot))
        const slotTime   = duration / sessions
        const work       = Math.min(this.maxWorkDuration,  Math.max(this.minWorkDuration,  Math.round(slotTime * workRatio / (workRatio + shortRatio))))
        const shortBreak = Math.min(this.maxBreakDuration, Math.max(this.minBreakDuration, Math.round(work * shortRatio / workRatio)))
        const longBreak  = Math.min(this.maxBreakDuration, Math.max(this.minBreakDuration, shortBreak * 3))

        this._targetDuration     = duration
        this._workDuration       = work
        this._shortBreakDuration = shortBreak
        this._longBreakDuration  = longBreak
        this._sessionsPerBlock   = sessions
        this.emit("config-changed")
    }

    //Configure
    configure(config: PomodoroConfig) {
        if (config.workDuration       !== undefined) this.workDuration       = config.workDuration
        if (config.shortBreakDuration !== undefined) this.shortBreakDuration = config.shortBreakDuration
        if (config.longBreakDuration  !== undefined) this.longBreakDuration  = config.longBreakDuration
        if (config.sessionsUntilLong  !== undefined) this.sessionsUntilLong  = config.sessionsUntilLong
        if (config.autoStart          !== undefined) this.autoStart          = config.autoStart
        if (config.sessionsPerBlock     !== undefined) this.sessionsPerBlock     = config.sessionsPerBlock
    }

    //Controller
    start() {
        if (this._running) return
        this._running = true
        this._waitingForConfirm = false
        this.notify("running")
        this._timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
            this._elapsed++
            this.notify("remaining")
            this.emit("tick")
            if (this._elapsed >= this.phaseDuration) this._completePhase()
            return GLib.SOURCE_CONTINUE
        })
        this.emit("started")
    }

    pause() {
        if (!this._running) return
        this._running = false
        this.notify("running")
        if (this._timer !== null) { GLib.source_remove(this._timer); this._timer = null }
        this.emit("paused")
    }

    toggle() { this._running ? this.pause() : this.start() }

    reset() {
        this.pause()
        this._elapsed = 0
        this._waitingForConfirm = false
        this.notify("remaining")
        this.emit("reset")
        this.emit("tick")
    }

    resetAll() {
        this.pause()
        this._elapsed       = 0
        this._sessionCount  = 0
        this._totalSessions = 0
        this._blockCount    = 0
        this._phase         = "idle"
        this._waitingForConfirm = false
        this._updateIconName()
        this.notify("phase")
        this.notify("remaining")
        this.emit("phase-changed", this._phase)
        this.emit("reset")
        this.emit("tick")
    }

    skipPhase() {
        this.pause()
        this._completePhase()
    }

    setPhase(phase: PomodoroPhase) {
        this.pause()
        this._phase   = phase
        this._elapsed = 0
        this._waitingForConfirm = false
        this._updateIconName()
        this.notify("phase")
        this.notify("remaining")
        this.emit("phase-changed", phase)
        this.emit("tick")
    }

    private _updateIconName() {
        const next = this._phase === "idle"        ? this.defaultSymbol
                   : this._phase === "work"        ? this.workSymbol
                   : this._phase === "short-break" ? this.shortBreakSymbol
                   : this.longBreakSymbol
        if (next === this._iconName) return
        this._iconName = next
        this.notify("icon-name")
    }

    private _completePhase() {
        this.pause()
        this.emit("phase-completed", this._phase)

        if (this._phase === "work") {
            this._sessionCount++
            this._totalSessions++
            this.emit("session-completed")
            this._phase = this._sessionCount % this._sessionsUntilLong === 0
                ? "long-break"
                : "short-break"
        } else if (this._phase === "long-break") {
            this._blockCount++
            this._phase = "work"
            this.emit("block-completed")
        } else {
            this._phase = "work"
        }

        if (this._sessionsPerBlock > 0 && this._sessionsPerBlock === this._sessionCount) {
            this._phase             = "idle"
            this._elapsed           = 0
            this._sessionCount      = 0
            this._waitingForConfirm = true
            this._updateIconName()
            this.notify("phase")
            this.notify("remaining")
            this.emit("phase-changed", this._phase)
            this.emit("tick")
            this.emit("target-reached")
            return
        }

        this._elapsed           = 0
        this._waitingForConfirm = !this.autoStart
        this._updateIconName()
        this.notify("phase")
        this.notify("remaining")
        this.emit("phase-changed", this._phase)
        this.emit("tick")

        if (this.autoStart) this.start()
    }
}
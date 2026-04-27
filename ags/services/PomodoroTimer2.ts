import GObject from "gi://GObject?version=2.0"
import { PomodoroPhase } from "./PomodoroTimer"
import getIconName from "../utils/getIconName"

type State = "idle" | "work" | "short-break" | "long-break"

interface Config {
    useWorkUntil?: boolean
    workUntil?: Date

    workSessionDuration_sec?: number
    shortBreakDuration_sec?: number
    longBreakDuration_sec?: number

    sessionsPerBlock?: number
    autoStartSession?: boolean
}

/**
 * Central limits
 */
export const LIMITS = {
    workSession: { min: 20 * 60, max: 60 * 60 },
    shortBreak:  { min: 5 * 60,  max: 10 * 60 },
    longBreak:   { min: 20 * 60, max: 30 * 60 },
} as const

/**
 * Default configuration
 */
const DEFAULT_CONFIG: Config = {
    useWorkUntil: false,
    workUntil: undefined,

    workSessionDuration_sec: LIMITS.workSession.min,
    shortBreakDuration_sec: LIMITS.shortBreak.min,
    longBreakDuration_sec: LIMITS.longBreak.min,

    sessionsPerBlock: 4,
    autoStartSession: false,
}

class PomodoroTimer extends GObject.Object {
    private m_config: Config
    private m_sessionTime: number = 0
    private m_sessionIndex: number = 0

    //Stats
    private m_phase: State     = "idle"
    private m_running          = false
    private m_iconName: string = "TODO"
    private m_remainingTime_sec: number = 0
    private m_sessionsCompleted: number = 0
    private m_blocksCompleted: number   = 0

    constructor(config: Config = {}) {
        super()

        this.m_config = {
            ...DEFAULT_CONFIG,
            ...config,
        }
    }

    //Getter
    get phase() {
        return this.m_phase
    }
    get running() {
        return this.m_running
    }
    get iconName() {
        return this.m_iconName
    }
    get remaining() {
        return this.m_remainingTime_sec
    }
    get sessionsCompleted() {
        return this.m_sessionsCompleted
    }
    get blocksCompleted() {
        return this.m_blocksCompleted
    }

    //Public API
    toggle() {
        this.m_running ? this.pause() : this.start()
    }

    start() {
        this.m_running = true 
        this.notify("running")

        this.emit("timer-started")
    }

    pause() {
        this.m_running = false
        this.notify("running")

        this.emit("timer-paused")
    }

    skipPhase() {
        
    }

    setPhase(phase: PomodoroPhase) {
        this.pause()
        this.m_phase = phase
        this.m_sessionTime = 0
        this.m_iconName = this.m_getIconName(phase)
        this.notify("phase")

        this.emit("phase-changed")
    }

    restartPhase() {
        this.emit("phase-reset")
    }

    completePhase() {

    }

    restartBlock() {
        this.emit("block-reset")
    }

    m_reset() {
        this.m_phase = "idle"
        this.m_running = false
        this.notify("phase")
        this.notify("running")
    }

    //Private helper
    private m_getNextPhase(phase: string): string {
        if(this.m_config.useWorkUntil === true && this.m_sessionTime === 0) return "idle"
        if(phase !== "work") return "work"
        if(phase === "work" && this.m_sessionIndex < this.m_config.sessionsPerBlock!) return "short-break"
        else return "long-break"
    }

    private m_getIconName(phase: string): string {
        switch(phase){
            case "idle":        return ""
            case "work":        return ""
            case "short-break": return ""
            case "long-break":  return ""
            default:            return ""
        }
    }
}

export default GObject.registerClass({
    GTypeName: "PomodoroTimer",
    Signals: {
        "phase-changed": {},
        "timer-paused": {},
        "timer-started": {},
        "phase-reset": {},
        "block-reset": {},
        "": {},
    },
    Properties: {
        running: GObject.ParamSpec.boolean("running", "Running", "Whether the timer is running.", GObject.ParamFlags.READABLE, false),
        phase: GObject.ParamSpec.string("phase", "Phase", "Phase the timer is in.", GObject.ParamFlags.READABLE, "idle"),
        remaining: GObject.ParamSpec.int("remaining", "Remaining", "Remaining time of the phase in seconds.", GObject.ParamFlags.READABLE, 0, 9999, 20*60),
        iconName: GObject.ParamSpec.string("iconName", "IconName", "Icon name for the current phase.", GObject.ParamFlags.READABLE, "TODO"),
        sessionsCompleted: GObject.ParamSpec.int("sessionsCompleted", "CompletedSessions", "Total number of completed sessions.", GObject.ParamFlags.READABLE, 0, 9999, 0),
        blocksCompleted: GObject.ParamSpec.int("blocksCompleted", "CompletedBlocks", "Total number of completed blocks.", GObject.ParamFlags.READABLE, 0, 9999, 0),
    },
}, PomodoroTimer)
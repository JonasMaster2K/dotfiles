import GObject from "gi://GObject?version=2.0"
import GLib from "gi://GLib?version=2.0"

type PomodoroPhase = "work" | "short-break" | "long-break" | "idle"

/**
 * Hilfsfunktion zur Begrenzung von Werten
 */
function clamp(x: number, min: number, max: number): number { 
    return Math.max(min, Math.min(x, max)); 
}

export default class PomodoroTimer extends GObject.Object {
    static{
        GObject.registerClass({
            GTypeName: "PomodoroTimer",
            Signals: {
                "timer-started": {},
                "timer-stopped": {},
                "phase-changed": {},
                "reset":         {},
            },
            Properties: {
                "running": GObject.ParamSpec.boolean(
                    "running", "Running", "Whether the timer is running", 
                    GObject.ParamFlags.READABLE, false
                ),
                "phase": GObject.ParamSpec.string(
                    "phase", "Phase", "Current pomodoro phase", 
                    GObject.ParamFlags.READABLE, "idle"
                ),
                "remaining": GObject.ParamSpec.int(
                    "remaining", "Remaining", "Seconds remaining in phase", 
                    GObject.ParamFlags.READABLE, 0, 999999, 0
                ),
                "work-session-time-sec": GObject.ParamSpec.int(
                    "work-session-time-sec", "Work Duration", "Duration of work session",
                    GObject.ParamFlags.READWRITE, 1500, 3000, 1500
                ),
                "short-break-time-sec": GObject.ParamSpec.int(
                    "short-break-time-sec", "Short Break Duration", "Duration of short break",
                    GObject.ParamFlags.READWRITE, 300, 600, 300
                ),
                "long-break-time-sec": GObject.ParamSpec.int(
                    "long-break-time-sec", "Long Break Duration", "Duration of long break",
                    GObject.ParamFlags.READWRITE, 900, 1800, 900
                ),
                "long-break-trigger": GObject.ParamSpec.int(
                    "long-break-trigger", "Long Break Trigger", "Work sessions before long break",
                    GObject.ParamFlags.READWRITE, 2, 4, 4
                ),
                "icon-name": GObject.ParamSpec.string (
                    "icon-name", "Icon Name", "Name of the current phase icon", 
                    GObject.ParamFlags.READABLE, "com.github.tomatoers.tomato"
                ),
            }
        }, this)
    }

    private readonly m_defaultSymbol:    string = "tomato"
    private readonly m_workSymbol:       string = "appointment-soon"
    private readonly m_shortBreakSymbol: string = "weather-clear"
    private readonly m_longBreakSymbol:  string = "go-home"

    // Interne Zustandsvariablen
    private m_running: boolean = false
    private m_current_phase: PomodoroPhase = "idle"
    private m_current_time: number = 0
    private m_timer: number = 0
    private m_work_session_count: number = 0
    private m_long_break_trigger: number = 4
    private m_current_icon_name: string = this.m_defaultSymbol

    // Konstanten für die Validierung
    public readonly min_work_session_time_sec = 25 * 60 
    public readonly max_work_session_time_sec = 50 * 60 
    public readonly min_short_break_time_sec  =  5 * 60 
    public readonly max_short_break_time_sec  = 10 * 60 
    public readonly min_long_break_time_sec   = 15 * 60 
    public readonly max_long_break_time_sec   = 30 * 60 
    public readonly min_long_break_trigger    = 2
    public readonly max_long_break_trigger    = 4

    // Dauer-Speicher
    private m_phase_durations: Record<PomodoroPhase, number> = {
        "work":        25 * 60,
        "short-break": 5 * 60,
        "long-break":  15 * 60,
        "idle":        0,
    }

    // --- GETTER & SETTER (GObject-kompatibel) ---

    get icon_name(): string { console.log(this.m_current_icon_name) 
        return this.m_current_icon_name; }

    get work_session_time_sec(): number { return this.m_phase_durations["work"]; }
    set work_session_time_sec(time: number) {
        const val = clamp(time, this.min_work_session_time_sec, this.max_work_session_time_sec);
        if (this.m_phase_durations["work"] !== val) {
            this.m_phase_durations["work"] = val;
            this.notify("work-session-time-sec");
            if (this.m_current_phase === "work") this.notify("remaining");
        }
    }

    get short_break_time_sec(): number { return this.m_phase_durations["short-break"]; }
    set short_break_time_sec(time: number) {
        const val = clamp(time, this.min_short_break_time_sec, this.max_short_break_time_sec);
        if (this.m_phase_durations["short-break"] !== val) {
            this.m_phase_durations["short-break"] = val;
            this.notify("short-break-time-sec");
            if (this.m_current_phase === "short-break") this.notify("remaining");
        }
    }

    get long_break_time_sec(): number { return this.m_phase_durations["long-break"]; }
    set long_break_time_sec(time: number) {
        const val = clamp(time, this.min_long_break_time_sec, this.max_long_break_time_sec);
        if (this.m_phase_durations["long-break"] !== val) {
            this.m_phase_durations["long-break"] = val;
            this.notify("long-break-time-sec");
            if (this.m_current_phase === "long-break") this.notify("remaining");
        }
    }

    get long_break_trigger(): number { return this.m_long_break_trigger; }
    set long_break_trigger(count: number) {
        const val = clamp(count, this.min_long_break_trigger, this.max_long_break_trigger);
        if (this.m_long_break_trigger !== val) {
            this.m_long_break_trigger = val;
            this.notify("long-break-trigger");
        }
    }

    get running(): boolean { return this.m_running; }
    get phase(): PomodoroPhase { return this.m_current_phase; }
    
    get remaining(): number {
        return Math.max(0, this.m_phase_durations[this.m_current_phase] - this.m_current_time);
    }

    // --- ÖFFENTLICHE METHODEN ---

    start(): void {
        if (this.m_running) return;
        
        this.m_running = true;
        if (this.m_current_phase === "idle") {
            this.m_current_phase = this.m_get_next_phase();
            this.m_current_icon_name = this.m_get_phase_icon_name(this.m_current_phase);
            this.notify("phase");
            this.notify("icon-name");
        }

        this.m_timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
            this.m_current_time++;
            this.notify("remaining");

            if (this.remaining <= 0) {
                this.m_complete_phase();
            }
            return GLib.SOURCE_CONTINUE;
        });

        this.notify("running");
        this.emit("timer-started");
    }

    stop(): void {
        if (!this.m_running) return;

        GLib.source_remove(this.m_timer);
        this.m_timer = 0;
        this.m_running = false;
        
        this.notify("running");
        this.emit("timer-stopped");
    }

    toggle(): void {
        this.m_running ? this.stop() : this.start();
    }

    skip(): void {
        this.m_complete_phase();
    }

    reset(): void {
        if (this.m_running) this.stop();
        
        this.m_current_phase = "idle";
        this.m_current_icon_name = this.m_get_phase_icon_name(this.m_current_phase);
        this.m_current_time = 0;
        this.m_work_session_count = 0;

        this.notify("icon-name");
        this.notify("phase");
        this.notify("remaining");
        this.emit("phase-changed");
        this.emit("reset");
    }

    // --- PRIVATE HELPER ---

    private m_get_next_phase(): PomodoroPhase { 
        if (this.m_current_phase !== "work") return "work";
        return (this.m_work_session_count < this.m_long_break_trigger) 
            ? "short-break" 
            : "long-break";
    }

    private m_get_phase_icon_name(phase: PomodoroPhase): string {
        switch(phase) {
            case "work": return this.m_workSymbol;
            case "short-break": return this. m_shortBreakSymbol;
            case "long-break": return this.m_longBreakSymbol;
            default: return this.m_defaultSymbol;
        }
    }

    private m_complete_phase(): void {
        if (this.m_current_phase === "work") {
            this.m_work_session_count++;
        } else if (this.m_current_phase === "long-break") {
            this.m_work_session_count = 0;
        }

        this.m_current_phase = this.m_get_next_phase();
        this.m_current_time = 0;
        this.m_current_icon_name = this.m_get_phase_icon_name(this.m_current_phase);

        this.notify("icon-name");
        this.notify("remaining");
        this.notify("phase");
        this.emit("phase-changed");
    }
}
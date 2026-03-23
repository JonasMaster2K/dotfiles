import GObject, { register, getter } from "ags/gobject"
import { readFile } from "ags/file"
import Gio from "gi://Gio?version=2.0"

type MemoryUsage = { percentage: number, total: number, used: number, free: number, available: number }
type CpuTime = { total: number, idle: number }
type NetStats = { rx: number, tx: number }
type DiskIO = { read: number, write: number }
type DiskUsage = { total: number, used: number, available: number, percentage: number }

const INTERVAL = 2000

@register({ GTypeName: "Usage" })
export default class Usage extends GObject.Object {

    static instance: Usage
    static get_default() {
        if (!this.instance) this.instance = new Usage()
        return this.instance
    }

    #cpuUsage: number = 0
    #cpuTemp: number = 0
    #cpuFreq: number = 0
    #cpuStats: CpuTime = { total: 0, idle: 0 }

    #memoryPercent: number = 0
    #memoryTotal: number = 0
    #memoryUsed: number = 0
    #memoryFree: number = 0
    #memoryAvailable: number = 0

    #swapTotal: number = 0
    #swapUsed: number = 0
    #swapFree: number = 0

    #netStats: NetStats = { rx: 0, tx: 0 }
    #netRx: number = 0
    #netTx: number = 0

    #diskIO: DiskIO = { read: 0, write: 0 }
    #diskRead: number = 0
    #diskWrite: number = 0

    #diskUsage: DiskUsage = { total: 0, used: 0, available: 0, percentage: 0 }
    #diskTotal: number = 0
    #diskUsed: number = 0
    #diskAvailable: number = 0
    #diskPercent: number = 0

    #loadAvg1: number = 0
    #loadAvg5: number = 0
    #loadAvg15: number = 0

    #uptime: number = 0
    #processCount: number = 0

    @getter(Number) get cpuUsage()        { return this.#cpuUsage }
    @getter(Number) get cpuTemp()         { return this.#cpuTemp }
    @getter(Number) get cpuFreq()         { return this.#cpuFreq }
    @getter(Number) get memoryPercent()   { return this.#memoryPercent }
    @getter(Number) get memoryTotal()     { return this.#memoryTotal }
    @getter(Number) get memoryUsed()      { return this.#memoryUsed }
    @getter(Number) get memoryFree()      { return this.#memoryFree }
    @getter(Number) get memoryAvailable() { return this.#memoryAvailable }
    @getter(Number) get swapTotal()       { return this.#swapTotal }
    @getter(Number) get swapUsed()        { return this.#swapUsed }
    @getter(Number) get swapFree()        { return this.#swapFree }
    @getter(Number) get netRx()           { return this.#netRx }
    @getter(Number) get netTx()           { return this.#netTx }
    @getter(Number) get diskRead()        { return this.#diskRead }
    @getter(Number) get diskWrite()       { return this.#diskWrite }
    @getter(Number) get diskTotal()       { return this.#diskTotal }
    @getter(Number) get diskUsed()        { return this.#diskUsed }
    @getter(Number) get diskAvailable()   { return this.#diskAvailable }
    @getter(Number) get diskPercent()     { return this.#diskPercent }
    @getter(Number) get loadAvg1()        { return this.#loadAvg1 }
    @getter(Number) get loadAvg5()        { return this.#loadAvg5 }
    @getter(Number) get loadAvg15()       { return this.#loadAvg15 }
    @getter(Number) get uptime()          { return this.#uptime }
    @getter(Number) get processCount()    { return this.#processCount }

    constructor() {
        super()

        this.setMemoryFields(this.getMemoryUsage())
        this.setSwapFields(this.getMemoryUsage())
        this.#cpuStats  = this.getCPUStats()
        this.#cpuTemp   = this.getCPUTemp()
        this.#cpuFreq   = this.getCPUFreq()
        this.#netStats  = this.getNetStats()
        this.#diskIO    = this.getDiskIO()
        this.setDiskUsage(this.getDiskUsage())
        this.setLoadAvg(this.getLoadAvg())
        this.#uptime    = this.getUptime()
        this.#processCount = this.getProcessCount()

        setInterval(() => {
            // CPU usage
            const stats  = this.getCPUStats()
            const dtotal = stats.total - this.#cpuStats.total
            const didle  = stats.idle  - this.#cpuStats.idle
            this.#cpuUsage = dtotal > 0 ? (dtotal - didle) / dtotal : 0
            this.#cpuStats = stats
            this.notify("cpu-usage")

            // CPU temp
            const temp = this.getCPUTemp()
            if (temp !== this.#cpuTemp) {
                this.#cpuTemp = temp
                this.notify("cpu-temp")
            }

            // CPU freq
            const freq = this.getCPUFreq()
            if (freq !== this.#cpuFreq) {
                this.#cpuFreq = freq
                this.notify("cpu-freq")
            }

            // Memory
            const mem = this.getMemoryUsage()
            this.setMemoryFields(mem)
            this.setSwapFields(mem)
            this.notify("memory-percent")
            this.notify("memory-total")
            this.notify("memory-used")
            this.notify("memory-free")
            this.notify("memory-available")
            this.notify("swap-total")
            this.notify("swap-used")
            this.notify("swap-free")

            // Network
            const net     = this.getNetStats()
            const elapsed = INTERVAL / 1000
            this.#netRx    = (net.rx - this.#netStats.rx) / elapsed
            this.#netTx    = (net.tx - this.#netStats.tx) / elapsed
            this.#netStats = net
            this.notify("net-rx")
            this.notify("net-tx")

            // Disk I/O
            const dio = this.getDiskIO()
            this.#diskRead  = (dio.read  - this.#diskIO.read)  / elapsed
            this.#diskWrite = (dio.write - this.#diskIO.write) / elapsed
            this.#diskIO    = dio
            this.notify("disk-read")
            this.notify("disk-write")

            // Disk usage (less frequent would be fine but keep it simple)
            this.setDiskUsage(this.getDiskUsage())
            this.notify("disk-total")
            this.notify("disk-used")
            this.notify("disk-available")
            this.notify("disk-percent")

            // Load average
            this.setLoadAvg(this.getLoadAvg())
            this.notify("load-avg1")
            this.notify("load-avg5")
            this.notify("load-avg15")

            // Uptime
            this.#uptime = this.getUptime()
            this.notify("uptime")

            // Process count
            this.#processCount = this.getProcessCount()
            this.notify("process-count")

        }, INTERVAL)
    }

    private getCPUStats(): CpuTime {
        const stat  = readFile("/proc/stat")
        const line  = stat.slice(0, stat.indexOf("\n"))
        const parts = line.replace(/^cpu\s+/, "").split(" ").map(Number)
        const idle  = parts[3] + parts[4]
        const total = parts.reduce((a, b) => a + b, 0)
        return { total, idle }
    }

    private getCPUTemp(): number {
        const paths = [
            "/sys/class/thermal/thermal_zone0/temp",
            "/sys/class/thermal/thermal_zone1/temp",
            "/sys/class/hwmon/hwmon0/temp1_input",
            "/sys/class/hwmon/hwmon1/temp1_input",
            "/sys/class/hwmon/hwmon2/temp1_input",
        ]
        for (const path of paths) {
            try {
                const val = Number(readFile(path).trim())
                if (!isNaN(val) && val > 0) return Math.round(val / 1000)
            } catch {}
        }
        return 0
    }

    private getCPUFreq(): number {
        try {
            const val = Number(readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq").trim())
            return isNaN(val) ? 0 : Math.round(val / 1000) // MHz
        } catch { return 0 }
    }

    private getMemoryUsage() {
        const dict = Object.fromEntries(
            readFile("/proc/meminfo")
                .split("\n")
                .map(line => {
                    const name    = line.slice(0, line.indexOf(":"))
                    const usageKb = Number(line.slice(line.indexOf(":") + 1).trim().replace(" kB", ""))
                    return [name, usageKb * 1024]
                })
        )
        return {
            total:      dict["MemTotal"]     ?? 0,
            free:       dict["MemFree"]      ?? 0,
            available:  dict["MemAvailable"] ?? 0,
            used:       (dict["MemTotal"] ?? 0) - (dict["MemFree"] ?? 0),
            percentage: dict["MemTotal"] > 0 ? ((dict["MemTotal"] - dict["MemAvailable"]) / dict["MemTotal"]) : 0,
            swapTotal:  dict["SwapTotal"]    ?? 0,
            swapFree:   dict["SwapFree"]     ?? 0,
            swapUsed:   (dict["SwapTotal"] ?? 0) - (dict["SwapFree"] ?? 0),
        }
    }

    private setMemoryFields(u: ReturnType<typeof this.getMemoryUsage>) {
        this.#memoryPercent   = u.percentage
        this.#memoryTotal     = u.total
        this.#memoryUsed      = u.used
        this.#memoryFree      = u.free
        this.#memoryAvailable = u.available
    }

    private setSwapFields(u: ReturnType<typeof this.getMemoryUsage>) {
        this.#swapTotal = u.swapTotal
        this.#swapUsed  = u.swapUsed
        this.#swapFree  = u.swapFree
    }

    private getNetStats(): NetStats {
        const lines = readFile("/proc/net/dev").split("\n").slice(2)
        let rx = 0, tx = 0
        for (const line of lines) {
            const parts = line.trim().split(/\s+/)
            if (!parts[0] || parts[0] === "lo:") continue
            rx += Number(parts[1]) || 0
            tx += Number(parts[9]) || 0
        }
        return { rx, tx }
    }

    private getDiskIO(): DiskIO {
        try {
            const lines = readFile("/proc/diskstats").split("\n")
            let read = 0, write = 0
            for (const line of lines) {
                const parts = line.trim().split(/\s+/)
                const name = parts[2]
                // nur physische Disks, keine Partitionen oder loop devices
                if (!name || name.startsWith("loop") || name.startsWith("dm-") || /\d$/.test(name)) continue
                read  += Number(parts[5])  || 0  // sectors read
                write += Number(parts[9])  || 0  // sectors written
            }
            return { read: read * 512, write: write * 512 } // sectors → bytes
        } catch { return { read: 0, write: 0 } }
    }

    private getDiskUsage(): DiskUsage {
        try {
            // statfs auf / via /proc/mounts wäre besser aber GJS hat keine direkte statfs API
            // Fallback: df via /proc/self/mountinfo ist nicht trivial, nutzen wir /proc/mounts + statvfs workaround
            // Einfachste Lösung: aus /proc/diskstats geht das nicht — wir lesen /proc/self/mounts
            // und nutzen Gio.File.query_filesystem_info
            const file = Gio.File.new_for_path("/")
            const info = file.query_filesystem_info("filesystem::*", null)
            const total     = info.get_attribute_uint64("filesystem::size")
            const available = info.get_attribute_uint64("filesystem::free")
            const used      = total - available
            const percentage = total > 0 ? used / total : 0
            return { total, used, available, percentage }
        } catch { return { total: 0, used: 0, available: 0, percentage: 0 } }
    }

    private setDiskUsage(u: DiskUsage) {
        this.#diskTotal     = u.total
        this.#diskUsed      = u.used
        this.#diskAvailable = u.available
        this.#diskPercent   = u.percentage
    }

    private getLoadAvg(): [number, number, number] {
        try {
            const parts = readFile("/proc/loadavg").trim().split(" ")
            return [parseFloat(parts[0]), parseFloat(parts[1]), parseFloat(parts[2])]
        } catch { return [0, 0, 0] }
    }

    private setLoadAvg([a, b, c]: [number, number, number]) {
        this.#loadAvg1  = a
        this.#loadAvg5  = b
        this.#loadAvg15 = c
    }

    private getUptime(): number {
        try {
            return parseFloat(readFile("/proc/uptime").trim().split(" ")[0])
        } catch { return 0 }
    }

    private getProcessCount(): number {
        try {
            const parts = readFile("/proc/loadavg").trim().split(" ")
            return parseInt(parts[3].split("/")[1]) || 0
        } catch { return 0 }
    }
}
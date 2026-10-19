pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ============================================================
    // Public API
    // ============================================================

    // Polling nur aktiv, wenn benötigt
    property bool enabled: false

    // %
    readonly property real cpuUsage: _cpuUsage

    // °C
    readonly property real cpuTemp: _cpuTemp

    // %
    readonly property real ramUsage: _ramUsage

    // bytes / second
    readonly property real networkRx: _networkRx
    readonly property real networkTx: _networkTx


    // ============================================================
    // Configuration
    // ============================================================

    // CPU + Network
    property int fastInterval: 1500

    // RAM
    property int ramInterval: 5000

    // Temperatur
    property int temperatureInterval: 5000

    // EMA smoothing
    //
    // 1.00 = kein smoothing
    // 0.50 = direkt
    // 0.25 = mittel
    // 0.15 = weich
    // 0.10 = sehr weich
    property real cpuSmoothing: 0.20
    property real networkSmoothing: 0.20


    // ============================================================
    // Internal state
    // ============================================================

    property real _cpuUsage: 0
    property real _cpuTemp: 0
    property real _ramUsage: 0

    property real _networkRx: 0
    property real _networkTx: 0

    property bool _cpuInitialized: false
    property bool _networkInitialized: false

    property double _lastCpuTotal: 0
    property double _lastCpuIdle: 0

    property double _lastRx: 0
    property double _lastTx: 0

    property double _lastNetworkTimestamp: 0


    // ============================================================
    // Helpers
    // ============================================================

    function ema(previous, current, factor) {
        return previous
            + factor
            * (current - previous)
    }


    // ============================================================
    // CPU
    // ============================================================

    FileView {
        id: cpuStat

        path: "/proc/stat"

        printErrors: false
        watchChanges: false

        onLoaded: {
            if (root.enabled)
                root.parseCpu()
        }
    }

    function parseCpu() {
        const data = cpuStat.text()

        if (!data)
            return

        const newline = data.indexOf("\n")

        const line =
            newline >= 0
                ? data.substring(0, newline)
                : data

        const values =
            line.trim().split(/\s+/)

        if (values.length < 5)
            return

        const user = Number(values[1])
        const nice = Number(values[2])
        const system = Number(values[3])
        const idle = Number(values[4])

        const iowait =
            values.length > 5
                ? Number(values[5])
                : 0

        const irq =
            values.length > 6
                ? Number(values[6])
                : 0

        const softirq =
            values.length > 7
                ? Number(values[7])
                : 0

        const steal =
            values.length > 8
                ? Number(values[8])
                : 0

        const idleTotal =
            idle + iowait

        const total =
            user
            + nice
            + system
            + idle
            + iowait
            + irq
            + softirq
            + steal

        if (root._lastCpuTotal > 0) {
            const totalDelta =
                total - root._lastCpuTotal

            const idleDelta =
                idleTotal - root._lastCpuIdle

            if (totalDelta > 0) {
                let raw =
                    ((totalDelta - idleDelta)
                    / totalDelta)
                    * 100

                raw = Math.max(
                    0,
                    Math.min(100, raw)
                )

                if (!root._cpuInitialized) {
                    root._cpuUsage = raw
                    root._cpuInitialized = true
                } else {
                    root._cpuUsage =
                        root.ema(
                            root._cpuUsage,
                            raw,
                            root.cpuSmoothing
                        )
                }
            }
        }

        root._lastCpuTotal = total
        root._lastCpuIdle = idleTotal
    }


    // ============================================================
    // RAM
    // ============================================================

    FileView {
        id: memInfo

        path: "/proc/meminfo"

        printErrors: false
        watchChanges: false

        onLoaded: {
            if (root.enabled)
                root.parseRam()
        }
    }

    function parseRam() {
        const data = memInfo.text()

        if (!data)
            return

        const lines =
            data.split("\n")

        let total = 0
        let available = 0

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i]

            if (line.startsWith("MemTotal:")) {
                total =
                    Number(
                        line
                            .substring(9)
                            .trim()
                            .split(/\s+/)[0]
                    )
            }

            else if (line.startsWith("MemAvailable:")) {
                available =
                    Number(
                        line
                            .substring(13)
                            .trim()
                            .split(/\s+/)[0]
                    )
            }

            if (
                total > 0
                && available > 0
            ) {
                break
            }
        }

        if (total <= 0)
            return

        const usage =
            ((total - available) / total)
            * 100

        root._ramUsage =
            Math.max(
                0,
                Math.min(100, usage)
            )
    }


    // ============================================================
    // CPU Temperature
    // ============================================================

    FileView {
        id: cpuTempFile

        // Hardwareabhängig
        path: "/sys/class/thermal/thermal_zone0/temp"

        printErrors: false
        watchChanges: false

        onLoaded: {
            if (root.enabled)
                root.parseTemperature()
        }
    }

    function parseTemperature() {
        const value =
            Number(cpuTempFile.text())

        if (!isFinite(value))
            return

        root._cpuTemp =
            value / 1000
    }


    // ============================================================
    // Network
    // ============================================================

    FileView {
        id: networkStat

        path: "/proc/net/dev"

        printErrors: false
        watchChanges: false

        onLoaded: {
            if (root.enabled)
                root.parseNetwork()
        }
    }

    function parseNetwork() {
        const data =
            networkStat.text()

        if (!data)
            return

        const lines =
            data.split("\n")

        let rx = 0
        let tx = 0

        /*
         * /proc/net/dev
         *
         * RX bytes = Feld 0
         * TX bytes = Feld 8
         *
         * Alle Interfaces außer lo werden addiert.
         */
        for (let i = 2; i < lines.length; ++i) {
            const line =
                lines[i].trim()

            if (!line)
                continue

            const colon =
                line.indexOf(":")

            if (colon < 0)
                continue

            const interfaceName =
                line
                    .substring(0, colon)
                    .trim()

            // Loopback ignorieren
            if (interfaceName === "lo")
                continue

            const fields =
                line
                    .substring(colon + 1)
                    .trim()
                    .split(/\s+/)

            if (fields.length < 16)
                continue

            const interfaceRx =
                Number(fields[0])

            const interfaceTx =
                Number(fields[8])

            if (isFinite(interfaceRx))
                rx += interfaceRx

            if (isFinite(interfaceTx))
                tx += interfaceTx
        }

        const now =
            Date.now()

        if (
            root._lastNetworkTimestamp > 0
            && root._lastRx >= 0
            && root._lastTx >= 0
        ) {
            const elapsed =
                (now - root._lastNetworkTimestamp)
                / 1000

            if (elapsed > 0) {
                const rxDelta =
                    rx - root._lastRx

                const txDelta =
                    tx - root._lastTx

                /*
                 * Negative Werte bedeuten normalerweise:
                 * Interface wurde neu gestartet / Counter reset.
                 */
                if (
                    rxDelta >= 0
                    && txDelta >= 0
                ) {
                    const rawRx =
                        rxDelta / elapsed

                    const rawTx =
                        txDelta / elapsed

                    if (!root._networkInitialized) {
                        root._networkRx =
                            rawRx

                        root._networkTx =
                            rawTx

                        root._networkInitialized =
                            true
                    } else {
                        root._networkRx =
                            root.ema(
                                root._networkRx,
                                rawRx,
                                root.networkSmoothing
                            )

                        root._networkTx =
                            root.ema(
                                root._networkTx,
                                rawTx,
                                root.networkSmoothing
                            )
                    }
                }
            }
        }

        root._lastRx =
            rx

        root._lastTx =
            tx

        root._lastNetworkTimestamp =
            now
    }


    // ============================================================
    // Polling
    // ============================================================

    function updateFast() {
        if (!root.enabled)
            return

        cpuStat.reload()
        networkStat.reload()
    }

    function updateRam() {
        if (!root.enabled)
            return

        memInfo.reload()
    }

    function updateTemperature() {
        if (!root.enabled)
            return

        cpuTempFile.reload()
    }

    function updateAll() {
        if (!root.enabled)
            return

        root.updateFast()
        root.updateRam()
        root.updateTemperature()
    }


    // ============================================================
    // Sampling reset
    // ============================================================

    function resetSampling() {
        /*
         * CPU
         */
        root._lastCpuTotal = 0
        root._lastCpuIdle = 0

        root._cpuInitialized = false

        /*
         * Network
         */
        root._lastRx = 0
        root._lastTx = 0
        root._lastNetworkTimestamp = 0

        root._networkInitialized = false
    }


    // ============================================================
    // Enabled / Disabled
    // ============================================================

    onEnabledChanged: {
        if (root.enabled) {
            /*
             * Frisches Messfenster starten.
             */
            root.resetSampling()

            /*
             * Sofort initiale Daten lesen.
             *
             * CPU und Network brauchen danach noch den
             * nächsten Tick für eine echte Delta-Messung.
             */
            root.updateAll()
        } else {
            root.resetSampling()

            /*
             * Optional Netzwerkwerte beim Einklappen auf 0.
             *
             * Entfernen, falls im UI lieber der letzte Wert
             * stehen bleiben soll.
             */
            root._networkRx = 0
            root._networkTx = 0
        }
    }


    // ============================================================
    // Timers
    // ============================================================

    Timer {
        interval: root.fastInterval
        running: root.enabled
        repeat: true

        onTriggered:
            root.updateFast()
    }

    Timer {
        interval: root.ramInterval
        running: root.enabled
        repeat: true

        onTriggered:
            root.updateRam()
    }

    Timer {
        interval: root.temperatureInterval
        running: root.enabled
        repeat: true

        onTriggered:
            root.updateTemperature()
    }
}
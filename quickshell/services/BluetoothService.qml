pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

import "../style"

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter ?? null

    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property string iconName: enabled
        ? "bluetooth-symbolic"
        : "bluetooth-disabled-symbolic"

    readonly property color iconColor: enabled
        ? Theme.foreground
        : Theme.warning

    readonly property var pairedDevices: adapter
        ? adapter.devices.values.filter(device =>
            device.paired && displayName(device) !== "")
        : []

    readonly property var availableDevices: adapter
        ? adapter.devices.values.filter(device =>
            !device.paired && displayName(device) !== "")
        : []

    // -------------------------------------------------------------------------
    // Pairing state
    // -------------------------------------------------------------------------

    property var pairingDevice: null

    readonly property bool pairingBusy: pairingDevice !== null

    property bool pairingPromptVisible: false
    property string pairingPasskey: ""
    property int pairingEntered: 0
    property string pairingDeviceName: ""

    readonly property int pairingPasskeyLength: pairingPasskey.length

    // -------------------------------------------------------------------------
    // Device helpers
    // -------------------------------------------------------------------------

    function isHardwareIdentifier(value): bool {
        const name = String(value || "").trim()

        if (!name)
            return true

        // Standard MAC address.
        const compact = name.replace(/[\s:.-]/g, "")

        if (/^[0-9a-f]{12}$/i.test(compact))
            return true

        // Hex-only advertising IDs.
        if (/^(?:0x)?[0-9a-f]{8,}$/i.test(name))
            return true

        // BlueZ-style dev_XX_XX_XX_XX_XX_XX path name.
        if (/^dev(?:[_:-][0-9a-f]{2}){6}$/i.test(name))
            return true

        return false
    }

    function displayName(device): string {
        if (!device)
            return ""

        const alias = String(device.name || "").trim()
        const advertised = String(device.deviceName || "").trim()

        if (!isHardwareIdentifier(alias))
            return alias

        if (!isHardwareIdentifier(advertised))
            return advertised

        return ""
    }

    function deviceIcon(device): string {
        const icon = String(device?.icon || "").trim()
        return icon || "bluetooth-symbolic"
    }

    function deviceBattery(device): string {
        if (!device?.batteryAvailable)
            return ""

        const battery = Math.max(0, Math.min(1, device.battery))
        return Math.round(battery * 100) + "%"
    }

    // -------------------------------------------------------------------------
    // Bluetooth adapter
    // -------------------------------------------------------------------------

    function toggleBluetooth(): void {
        if (!adapter)
            return

        adapter.enabled = !adapter.enabled
    }

    function toggleScan(): void {
        if (!adapter || !adapter.enabled)
            return

        if (scanTimer.running) {
            stopScan()
        } else {
            startScan()
        }
    }

    function startScan(): void {
        if (!adapter || !adapter.enabled || pairingBusy)
            return

        adapter.discovering = true
        scanTimer.restart()
    }

    function stopScan(): void {
        if (!adapter)
            return

        adapter.discovering = false
        scanTimer.stop()
    }

    // -------------------------------------------------------------------------
    // Device actions
    // -------------------------------------------------------------------------

    function connectDevice(device): void {
        if (!adapter || !adapter.enabled || !device)
            return

        if (device.connected || device.pairing)
            return

        device.connect()
    }

    function disconnectDevice(device): void {
        if (!device || !device.connected)
            return

        device.disconnect()
    }

    function forgetDevice(device): void {
        if (!device || !device.paired || device.pairing)
            return

        device.forget()
    }

    function toggleTrust(device): void {
        if (!adapter || !adapter.enabled || !device || device.pairing)
            return

        device.trusted = !device.trusted
    }

    // -------------------------------------------------------------------------
    // Pairing
    // -------------------------------------------------------------------------

    function pairDevice(device): void {
        if (!adapter || !adapter.enabled || !device)
            return

        if (pairingBusy) {
            console.warn(
                "Bluetooth pairing already active:",
                pairingDeviceName
            )
            return
        }

        if (device.paired || device.pairing)
            return

        if (adapter.discovering || scanTimer.running)
            stopScan()

        pairingDevice = device
        pairingDeviceName = displayName(device)

        pairingPasskey = ""
        pairingEntered = 0

        // sofort öffnen
        pairingPromptVisible = true

        console.log(
            "Starting Bluetooth pairing:",
            pairingDeviceName
        )

        device.pair()
    }

    function finishPairing(): void {
        if (pairingDevice) {
            console.log(
                "Bluetooth pairing finished:",
                pairingDeviceName
            )
        }

        pairingDevice = null

        clearPairingPrompt()
    }

    function clearPairingPrompt(): void {
        pairingPromptVisible = false
        pairingPasskey = ""
        pairingEntered = 0
        pairingDeviceName = ""
    }

    // Observe the device currently being paired.
    Connections {
        target: root.pairingDevice
        enabled: root.pairingDevice !== null

        function onPairedChanged() {
            if (!root.pairingDevice)
                return

            console.log(
                "Bluetooth paired changed:",
                root.pairingDevice.paired
            )

            if (root.pairingDevice.paired)
                root.finishPairing()
        }

        function onPairingChanged() {
            if (!root.pairingDevice)
                return

            console.log(
                "Bluetooth pairing changed:",
                root.pairingDevice.pairing
            )

            /*
             * If pairing stopped and the device did not become paired,
             * the attempt failed/cancelled.
             */
            if (!root.pairingDevice.pairing
                    && !root.pairingDevice.paired) {
                root.finishPairing()
            }
        }
    }

    // -------------------------------------------------------------------------
    // bluetoothctl agent output
    // -------------------------------------------------------------------------

    function stripAnsi(value): string {
        /*
         * bluetoothctl is an interactive terminal application and outputs
         * ANSI escape/control sequences. Remove the common ones before
         * parsing human-readable content.
         */
        return String(value || "")
            .replace(/\x1B\[[0-?]*[ -/]*[@-~]/g, "")
            .replace(/\r/g, "")
    }

    function handleAgentOutput(data): void {
        const raw = String(data || "")

        console.log("BT RAW:", JSON.stringify(raw))

        // -------------------------------------------------------------
        // Passkey + entered aus der ANSI-Ausgabe von bluetoothctl lesen
        // -------------------------------------------------------------

        /*
        * bluetoothctl erzeugt sinngemäß:
        *
        * Passkey:
        *   BOLDGRAY + bereits eingegebene Ziffern
        *   BOLDWHITE + restliche Ziffern
        *
        * Dadurch können wir die Länge des grauen Blocks als "entered"
        * verwenden.
        */

        const passkeyIndex = raw.indexOf("Passkey:")

        if (passkeyIndex !== -1) {
            const passkeyPart = raw.substring(passkeyIndex)

            // Alle ANSI-Codes entfernen -> eigentlichen Passkey bekommen.
            const cleanPasskeyPart = stripAnsi(passkeyPart)

            const passkeyMatch = cleanPasskeyPart.match(
                /Passkey:\s*([0-9]{6})/
            )

            if (passkeyMatch) {
                pairingPasskey = passkeyMatch[1]
                pairingPromptVisible = true
            }

            /*
            * bluetoothctl benutzt für den bereits eingegebenen Teil:
            *
            * \x1b[1;90m   bzw. je nach Build/Terminal eine ähnliche
            * ANSI-Sequenz für "bold gray".
            *
            * Danach kommt der noch nicht eingegebene Teil mit bold white.
            *
            * Wir suchen deshalb nach:
            *
            * gray ANSI
            * digits
            * white ANSI
            */
            const enteredMatch = passkeyPart.match(
                /\x1B\[[0-9;]*90m([0-9]{0,6})\x1B\[[0-9;]*97m/
            )

            if (enteredMatch) {
                pairingEntered = enteredMatch[1].length

                console.log(
                    "Bluetooth entered:",
                    pairingEntered
                )
            }

            console.log(
                "Bluetooth passkey:",
                pairingPasskey,
                "entered:",
                pairingEntered
            )

            return
        }

        // -------------------------------------------------------------
        // PIN
        // -------------------------------------------------------------

        const text = stripAnsi(raw)

        const pinMatch = text.match(
            /PIN(?:\s+code)?:\s*([0-9]+)/i
        )

        if (pinMatch) {
            pairingPasskey = pinMatch[1]
            pairingEntered = 0
            pairingPromptVisible = true

            console.log(
                "Bluetooth PIN:",
                pairingPasskey
            )

            return
        }

        // -------------------------------------------------------------
        // Abschluss / Fehler
        // -------------------------------------------------------------

        if (
            text.includes("Pairing successful")
            || text.includes("AuthenticationCanceled")
            || text.includes("AuthenticationFailed")
            || text.includes("AuthenticationRejected")
        ) {
            finishPairing()
        }
    }

    // -------------------------------------------------------------------------
    // Scan timer
    // -------------------------------------------------------------------------

    Timer {
        id: scanTimer

        interval: 5000
        repeat: false

        onTriggered: {
            if (root.adapter)
                root.adapter.discovering = false
        }
    }

    // -------------------------------------------------------------------------
    // BlueZ pairing agent
    // -------------------------------------------------------------------------

    Process {
        id: bluetoothAgent

        running: true

        command: [
            "bluetoothctl",
            "--agent",
            "KeyboardDisplay"
        ]

        stdout: SplitParser {
            onRead: data => root.handleAgentOutput(data)
        }

        stderr: SplitParser {
            onRead: data => {
                console.warn(
                    "BT ERR:",
                    JSON.stringify(data)
                )
            }
        }
    }
}
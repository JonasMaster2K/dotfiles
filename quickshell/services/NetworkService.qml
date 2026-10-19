pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "../style"
Singleton {
    id: root
    // Properties
    property string ipAddress: "—"
    property int wifiFrequency: 0
    property string uploadSpeed: "0.0 Mbit/s"
    property string downloadSpeed: "0.0 Mbit/s"
    property string ping: "0.0 ms"
    property bool speedtestAvailable: false
    // Available WLANs
    // { name, signal, security, frequency, connected }
    property var availableNetworks: []
    // Saved VPN profiles
    // { uuid, name, type, connected, status }
    property var vpnConnections: []
    // Live network activity in Mbit/s
    property real currentDownload: 0
    property real currentUpload: 0
    // Last 3600 activity samples (1 hour at 1 sample/sec) for the graph
    property var activityHistory: []
    // Internal state
    property var _vpnProfiles: []
    property var _activeVpnIds: []
    property string _ipInterface: ""
    property string _wifiFrequencyInterface: ""
    property string _trafficInterface: ""
    property real _lastRx: -1
    property real _lastTx: -1
    property real _lastSampleTime: 0
    property string _vpnActionUuid: ""
    // Pending action is kept for Quickshell's asynchronous connection signals.
    property var _wifiPendingNetwork: null
    signal wifiPasswordRequired(string ssid)
    signal wifiConnectionError(string ssid, string message)
    // Derived properties
    readonly property var device: getActiveDevice()
    readonly property var wifiDevice: getWifiDevice()
    readonly property var wiredDevice: getWiredDevice()
    readonly property var activeNetwork: getActiveNetwork()
    readonly property bool connected: isConnected()
    readonly property bool isWifi: getIsWifi()
    readonly property bool isWired: getIsWired()
    readonly property bool wifiEnabled: getWifiEnabled()
    readonly property bool wifiAcquiring: isWifiAcquiring()
    readonly property bool vpn: isVpnConnected()
    readonly property bool vpnBusy: vpnAction.running
    readonly property bool speedtestRunning: speedtestCheck.running
    readonly property int wifiStrength: getWifiStrength()
    readonly property string name: getNetworkName()
    readonly property string type: getNetworkType()
    readonly property string frequencyBand: getFrequencyBand()
    readonly property string linkSpeed: getLinkSpeed()
    readonly property string iconName: getIconName()
    readonly property color iconColor: getIconColor()
    readonly property color connectivityColor: getConnectivityColor()
    readonly property string connectivityString: getConnectivityString()
    readonly property string signalLabel: getSignalLabel()
    readonly property string currentDownloadString: formatSpeed(currentDownload)
    readonly property string currentUploadString: formatSpeed(currentUpload)
    // Device functions
    function getActiveDevice() {
        const devices = Networking.devices.values
        for (const item of devices) {
            if (item.type == DeviceType.Wired && item.connected)
                return item
        }
        for (const item of devices) {
            if (item.type == DeviceType.Wifi && item.connected)
                return item
        }
        return null
    }
    function getWifiDevice() {
        for (const item of Networking.devices.values) {
            if (item.type == DeviceType.Wifi)
                return item
        }
        return null
    }
    function getWiredDevice() {
        for (const item of Networking.devices.values) {
            if (item.type == DeviceType.Wired)
                return item
        }
        return null
    }
    function getActiveNetwork() {
        if (!device)
            return null
        if (device.type == DeviceType.Wired)
            return device.network ?? null
        for (const network of device.networks.values) {
            if (network.connected)
                return network
        }
        return null
    }
    function getNetworkName(): string {
        return activeNetwork?.name
            ?? (isWired ? "Ethernet" : "Unknown")
    }
    function isConnected(): bool {
        return device?.connected ?? false
    }
    function getIsWifi(): bool {
        return device?.type == DeviceType.Wifi
    }
    function getIsWired(): bool {
        return device?.type == DeviceType.Wired
    }
    function getWifiEnabled(): bool {
        return Networking.wifiEnabled
    }
    function getNetworkType(): string {
        if (isWired)
            return "WIRED"
        if (isWifi)
            return "WIFI"
        return "NONE"
    }
    function isWifiAcquiring(): bool {
        for (const item of Networking.devices.values) {
            if (item.type != DeviceType.Wifi)
                continue
            for (const network of item.networks.values) {
                if (network.stateChanging && !network.connected)
                    return true
            }
        }
        return false
    }
    function getWifiStrength(): int {
        if (!isWifi || !activeNetwork)
            return 0
        return Math.round(activeNetwork.signalStrength * 100)
    }
    function getFrequencyBand(): string {
        if (!isWifi || wifiFrequency <= 0)
            return "—"
        if (wifiFrequency >= 2400 && wifiFrequency <= 2500)
            return "2.4 GHz"
        if (wifiFrequency >= 4900 && wifiFrequency < 5925)
            return "5 GHz"
        if (wifiFrequency >= 5925 && wifiFrequency <= 7125)
            return "6 GHz"
        return "—"
    }
    function getLinkSpeed(): string {
        if (!isWired || !device?.connected)
            return "—"
        const speed = device.linkSpeed
        if (!speed || speed <= 0)
            return "—"
        if (speed >= 1000)
            return (speed / 1000).toFixed(1) + " Gbit/s"
        return speed + " Mbit/s"
    }
    // Connectivity functions
    function getConnectivityString(): string {
        if (!connected)
            return "Disconnected"
        if (isWired)
            return getLinkSpeed()
        if (wifiStrength >= 80)
            return "Excellent"
        if (wifiStrength >= 60)
            return "Good"
        if (wifiStrength >= 40)
            return "Ok"
        if (wifiStrength >= 20)
            return "Weak"
        return "Bad"
    }
    function getSignalLabel(): string {
        if (isWired)
            return "Link speed"
        return "Signal"
    }
    function getConnectivityColor(): color {
        if (wifiAcquiring)
            return Theme.foreground
        if (!device)
            return Theme.warning
        if (Networking.connectivity != NetworkConnectivity.Full)
            return Theme.error
        return Theme.success
    }
    // Icon functions
    function getWifiIcon(): string {
        if (wifiStrength >= 80)
            return "network-wireless-signal-excellent-symbolic"
        if (wifiStrength >= 60)
            return "network-wireless-signal-good-symbolic"
        if (wifiStrength >= 40)
            return "network-wireless-signal-ok-symbolic"
        if (wifiStrength >= 20)
            return "network-wireless-signal-weak-symbolic"
        return "network-wireless-signal-none-symbolic"
    }
    function getIconName(): string {
        if (vpn)
            return "network-vpn-enabled-symbolic"
        if (wifiAcquiring)
            return "network-wireless-acquiring-symbolic"
        if (!device)
            return "network-wireless-disabled-symbolic"
        if (isWired) {
            if (Networking.connectivity != NetworkConnectivity.Full)
                return "network-wired-disconnected-symbolic"
            return "network-wired-symbolic"
        }
        if (isWifi)
            return getWifiIcon()
        return "network-wireless-disabled-symbolic"
    }
    function getIconColor(): color {
        if (wifiAcquiring)
            return Theme.foreground
        if (!device)
            return Theme.warning
        if (Networking.connectivity != NetworkConnectivity.Full)
            return Theme.error
        return Theme.foreground
    }
    // Update functions
    function updateNetwork() {
        updateIpAddress()
        updateWifiDetails()
        updateWifiNetworks()
        updateVpnConnections()
    }
    function updateIpAddress() {
        if (!device) {
            ipAddress = "—"
            return
        }
        if (ipAddressCheck.running)
            return
        _ipInterface = device.name
        ipAddressCheck.command = [
            "nmcli", "-g", "IP4.ADDRESS",
            "device", "show", _ipInterface
        ]
        ipAddressCheck.running = true
    }
    function updateWifiDetails() {
        if (!isWifi || !device) {
            wifiFrequency = 0
            return
        }
        const interfaceName = device.name
        // Read the connected WLAN frequency from NetworkManager.
        if (!wifiFrequencyCheck.running) {
            _wifiFrequencyInterface = interfaceName
            wifiFrequencyCheck.command = [
                "nmcli", "-t", "-f", "IN-USE,FREQ",
                "device", "wifi", "list",
                "ifname", interfaceName, "--rescan", "no"
            ]
            wifiFrequencyCheck.running = true
        }
    }
    function updateWifiNetworks() {
        if (!wifiDevice || !wifiEnabled) {
            availableNetworks = []
            return
        }
        if (wifiListCheck.running)
            return
        wifiListCheck.command = [
            "nmcli", "-t", "--escape", "yes",
            "-f", "IN-USE,SSID,SIGNAL,SECURITY,FREQ,BSSID,RATE,CHAN",
            "device", "wifi", "list",
            "ifname", wifiDevice.name,
            "--rescan", "no"
        ]
        wifiListCheck.running = true
    }
    function refreshWifiNetworks() {
        if (!wifiDevice || !wifiEnabled)
            return
        if (wifiRescan.running || wifiListCheck.running)
            return
        wifiRescan.command = [
            "nmcli", "device", "wifi", "rescan",
            "ifname", wifiDevice.name
        ]
        wifiRescan.running = true
    }
    function updateVpnConnections() {
        if (!vpnProfilesCheck.running)
            vpnProfilesCheck.running = true
        if (!vpnActiveCheck.running)
            vpnActiveCheck.running = true
    }
    function updateSpeedtest() {
        if (!connected
                || Networking.connectivity != NetworkConnectivity.Full
                || speedtestCheck.running)
            return
        speedtestCheck.running = true
    }
    // WLAN controls
    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled
    }
    function toggleWifi() {
        setWifiEnabled(!wifiEnabled)
    }
    function getWifiNetwork(ssid) {
        if (!wifiDevice)
            return null
        for (const network of wifiDevice.networks.values) {
            if (network.name === ssid)
                return network
        }
        return null
    }
    function connectWifi(ssid, password, secured, security) {
        if (!wifiEnabled || !wifiDevice)
            return false
        const network = getWifiNetwork(ssid)
        if (!network) {
            wifiConnectionError(ssid, "Network is no longer available. Refresh the list.")
            return false
        }
        if (network.connected || network.stateChanging)
            return false
        // Enterprise authentication requires a different credentials flow.
        if (secured && /802\.1x|eap|enterprise/i.test(security || "")) {
            wifiConnectionError(ssid, "Enterprise Wi-Fi is not supported by this dialog yet.")
            return false
        }
        // Quickshell exposes saved NetworkManager profiles via 'known'.
        // Avoid asking for a password if an existing profile can be reused.
        if (secured && !network.known && !password) {
            wifiPasswordRequired(ssid)
            return true
        }
        _wifiPendingNetwork = network
        if (password)
            network.connectWithPsk(password)
        else
            network.connect()
        return true
    }
    function disconnectWifi() {
        if (!wifiDevice?.connected)
            return false
        wifiDevice.disconnect()
        return true
    }
    Connections {
        target: root._wifiPendingNetwork
        ignoreUnknownSignals: true
        function onConnectionFailed(reason) {
            const network = root._wifiPendingNetwork
            if (!network)
                return
            if (reason === ConnectionFailReason.NoSecrets)
                root.wifiPasswordRequired(network.name)
            else
                root.wifiConnectionError(network.name,
                    "Connection failed. Please try again.")
            root._wifiPendingNetwork = null
        }
        function onConnectedChanged() {
            const network = root._wifiPendingNetwork
            if (network && network.connected) {
                root._wifiPendingNetwork = null
                root.updateWifiNetworks()
            }
        }
    }
    // LAN controls
    function toggleLan() {
        if (!wiredDevice || lanAction.running)
            return
        lanAction.command = wiredDevice.connected
            ? ["nmcli", "device", "disconnect", wiredDevice.name]
            : ["nmcli", "device", "connect", wiredDevice.name]
        lanAction.running = true
    }
    // VPN functions
    function isVpnConnected(): bool {
        for (const connection of vpnConnections) {
            if (connection.connected)
                return true
        }
        return false
    }
    function getVpnConnection(uuid) {
        for (const connection of vpnConnections) {
            if (connection.uuid == uuid)
                return connection
        }
        return null
    }
    function connectVpn(uuid) {
        if (vpnAction.running)
            return
        const connection = getVpnConnection(uuid)
        if (!connection || connection.connected)
            return
        _vpnActionUuid = uuid
        vpnAction.command = [
            "nmcli", "connection", "up", "uuid", uuid
        ]
        vpnAction.running = true
    }
    function disconnectVpn(uuid) {
        if (vpnAction.running)
            return
        const connection = getVpnConnection(uuid)
        if (!connection || !connection.connected)
            return
        _vpnActionUuid = uuid
        vpnAction.command = [
            "nmcli", "connection", "down", "uuid", uuid
        ]
        vpnAction.running = true
    }
    function toggleVpn(uuid) {
        const connection = getVpnConnection(uuid)
        if (!connection || vpnAction.running)
            return
        if (connection.connected)
            disconnectVpn(uuid)
        else
            connectVpn(uuid)
    }
    function rebuildVpnConnections() {
        const result = []
        for (const profile of _vpnProfiles) {
            const active = _activeVpnIds.indexOf(profile.uuid) !== -1
            result.push({
                uuid: profile.uuid,
                name: profile.name,
                type: profile.type,
                connected: active,
                status: active ? "Connected" : "Disabled"
            })
        }
        result.sort((a, b) => {
            if (a.connected != b.connected)
                return a.connected ? -1 : 1
            return a.name.localeCompare(b.name)
        })
        vpnConnections = result
    }
    // Parsing functions
    // Splits nmcli's escaped colon-separated output.
    function splitNmcli(line) {
        const result = []
        let value = ""
        let escaped = false
        for (let i = 0; i < line.length; i++) {
            const char = line[i]
            if (escaped) {
                value += char
                escaped = false
            } else if (char == "\\") {
                escaped = true
            } else if (char == ":") {
                result.push(value)
                value = ""
            } else {
                value += char
            }
        }
        if (escaped)
            value += "\\"
        result.push(value)
        return result
    }
    function parseWifiNetworks(output) {
        const networks = {}
        for (const line of output.trim().split("\n")) {
            if (!line) continue
            const fields = splitNmcli(line)
            if (fields.length < 8) continue
            const name = fields[1]
            if (!name) continue
            const bssid = fields[5] || ""
            // Zufalls-MAC / Hotspot-Erkennung über das 2. Zeichen der BSSID
            const secondChar = bssid.length > 1 ? bssid[1].toLowerCase() : ""
            const isLocallyAdministered = ["2", "6", "a", "e"].includes(secondChar)
            const rawFreq = fields[4] // z.B. "2412 MHz" oder "2.4 GHz"
            const freqMHz = parseInt(rawFreq, 10) || 0
            const entry = {
                name: name,                             // String
                bssid: bssid,                           // String
                signal: Number(fields[2]) || 0,         // Number (int)
                security: fields[3],                    // String
                frequency: freqMHz,                     // Number (int in MHz)
                rate: parseInt(fields[6], 10) || 0,     // Number (int in Mbit/s)
                channel: parseInt(fields[7], 10) || 0,  // Number (int)
                secured: fields[3] !== "" && fields[3] !== "--", // Boolean
                connected: fields[0] === "*",           // Boolean
                isHotspot: isLocallyAdministered        // Boolean
            }
            if (!networks[name] || entry.signal > networks[name].signal || entry.connected) {
                networks[name] = entry
            }
        }
        const result = Object.values(networks)
        result.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            return b.signal - a.signal
        })
        availableNetworks = result
    }
    function parseWifiFrequency(output) {
        for (const line of output.split("\n")) {
            const match = line.trim().match(/^\*:(\d+)/)
            if (match) {
                wifiFrequency = Number(match[1])
                return
            }
        }
        console.warn("Connected WLAN frequency not found in nmcli output")
    }
    function parseVpnProfiles(output) {
        const profiles = []
        for (const line of output.trim().split("\n")) {
            if (!line)
                continue
            const fields = splitNmcli(line)
            if (fields.length < 3)
                continue
            const uuid = fields[0]
            const type = fields[1]
            const name = fields.slice(2).join(":")
            if (type != "vpn" && type != "wireguard")
                continue
            profiles.push({
                uuid: uuid,
                name: name,
                type: type
            })
        }
        _vpnProfiles = profiles
        rebuildVpnConnections()
    }
    function parseActiveVpns(output) {
        _activeVpnIds = output.trim()
            ? output.trim().split("\n").map(s => s.trim())
            : []
        rebuildVpnConnections()
    }
    // Network activity functions
    function formatSpeed(value): string {
        if (value < 0.1)
            return (value * 1000).toFixed(0) + " Kbit/s"
        return value.toFixed(1) + " Mbit/s"
    }
    function updateActivity() {
        if (!device) {
            currentDownload = 0
            currentUpload = 0
            resetActivity()
            return
        }
        if (trafficCheck.running)
            return
        _trafficInterface = device.name
        trafficCheck.command = [
            "cat",
            "/sys/class/net/" + _trafficInterface + "/statistics/rx_bytes",
            "/sys/class/net/" + _trafficInterface + "/statistics/tx_bytes"
        ]
        trafficCheck.running = true
    }
    function resetActivity() {
        _lastRx = -1
        _lastTx = -1
        _lastSampleTime = 0
        activityHistory = []
    }
    function parseActivity(output) {
        const values = output.trim().split(/\s+/)
        if (values.length < 2)
            return
        const rx = Number(values[0])
        const tx = Number(values[1])
        const now = Date.now()
        if (!Number.isFinite(rx) || !Number.isFinite(tx))
            return
        if (_lastRx >= 0 && _lastSampleTime > 0) {
            const seconds = (now - _lastSampleTime) / 1000
            if (seconds > 0 && rx >= _lastRx && tx >= _lastTx) {
                currentDownload =
                    ((rx - _lastRx) * 8) / seconds / 1000000
                currentUpload =
                    ((tx - _lastTx) * 8) / seconds / 1000000
                const history = activityHistory.slice()
                history.push({
                    time: now,
                    down: currentDownload,
                    up: currentUpload
                })
                while (history.length > 3600)
                    history.shift()
                activityHistory = history
            }
        }
        _lastRx = rx
        _lastTx = tx
        _lastSampleTime = now
    }
    // Processes
    Process {
        id: ipAddressCheck
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.device?.name != root._ipInterface)
                    return
                const address = text.trim().split("\n")[0]
                root.ipAddress = address
                    ? address.split("/")[0]
                    : "—"
            }
        }
    }
    Process {
        id: wifiFrequencyCheck
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.device?.name != root._wifiFrequencyInterface)
                    return
                root.parseWifiFrequency(text)
            }
        }
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("WLAN frequency query failed:", code)
        }
    }
    Process {
        id: wifiListCheck
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.wifiEnabled)
                    root.parseWifiNetworks(text)
            }
        }
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("WLAN list failed:", code)
        }
    }
    Process {
        id: wifiRescan
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("WLAN scan failed:", code)
            root.updateWifiNetworks()
        }
    }
    Process {
        id: vpnProfilesCheck
        command: [
            "nmcli", "-t", "--escape", "yes",
            "-f", "UUID,TYPE,NAME",
            "connection", "show"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.parseVpnProfiles(text)
        }
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("VPN profiles failed:", code)
        }
    }
    Process {
        id: vpnActiveCheck
        command: [
            "nmcli", "-t", "-f", "UUID",
            "connection", "show", "--active"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.parseActiveVpns(text)
        }
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("VPN status failed:", code)
        }
    }
    Process {
        id: vpnAction
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("VPN action failed:", root._vpnActionUuid, code)
            root.updateVpnConnections()
        }
    }
    Process {
        id: lanAction
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("LAN action failed:", code)
            root.updateNetwork()
        }
    }
    Process {
        id: speedtestCheck
        command: [
            "timeout", "120s",
            "speedtest-cli", "--json", "--secure"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text)
                    if (!Number.isFinite(result.download)
                            || !Number.isFinite(result.upload)
                            || !Number.isFinite(result.ping))
                        throw new Error("Invalid speedtest values")
                    root.downloadSpeed =
                        (result.download / 1000000).toFixed(1) + " Mbit/s"
                    root.uploadSpeed =
                        (result.upload / 1000000).toFixed(1) + " Mbit/s"
                    root.ping = result.ping.toFixed(1) + " ms"
                    root.speedtestAvailable = true
                } catch (error) {
                    console.warn("Speedtest:", error)
                }
            }
        }
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("Speedtest failed:", code)
        }
    }
    Process {
        id: trafficCheck
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.device?.name != root._trafficInterface)
                    return
                root.parseActivity(text)
            }
        }
    }
    Process {
        id: networkMonitor
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: networkRefreshTimer.restart()
        }
    }
    // Timers
    Timer {
        id: networkRefreshTimer
        interval: 800
        repeat: false
        onTriggered: root.updateNetwork()
    }
    Timer {
        id: wifiRefreshTimer
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.updateWifiNetworks()
    }
    Timer {
        id: activityTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateActivity()
    }
    Timer {
        id: speedtestTimer
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.updateSpeedtest()
    }
    // Change handlers
    onDeviceChanged: {
        resetActivity()
        currentDownload = 0
        currentUpload = 0
        ipAddress = "—"
        wifiFrequency = 0
        networkRefreshTimer.restart()
    }
    Connections {
        target: Networking
        function onConnectivityChanged() {
            if (Networking.connectivity == NetworkConnectivity.Full
                    && !root.speedtestAvailable) {
                root.updateSpeedtest()
            }
        }
        function onWifiEnabledChanged() {
            root.updateWifiNetworks()
        }
    }
    onWifiDeviceChanged: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = true
    }
    // Initialization
    Component.onCompleted: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = true
        updateNetwork()
        updateActivity()
        updateSpeedtest()
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

import "../style"

Singleton{
    readonly property UPowerDevice device: UPower.displayDevice

    readonly property string iconName: "battery-level-" + Math.floor(device.percentage * 10) * 10 + (device.state == UPowerDeviceState.Charging ? "-charging-symbolic" : "-symbolic")
    readonly property color iconColor: charging ? Theme.success : level <= 10 ? Theme.error : level <= 30 ? Theme.warning : Theme.foreground

    readonly property int level: device.percentage * 100

    readonly property real timeToEmpty: device.timeToEmpty

    readonly property real timeToFull: device.timeToFull

    readonly property bool charging: device.state == UPowerDeviceState.Charging

    function formatTime(seconds) {
        const totalMinutes = Math.floor(seconds / 60)
        const hours = Math.floor(totalMinutes / 60)
        const minutes = totalMinutes % 60

        if (hours > 0)
            return hours + "h " + minutes + "min"

        return minutes + "min"
    }
}
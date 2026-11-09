pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

import "../style"

Singleton {
    id: root

    // UPOWER

    readonly property UPowerDevice device: UPower.displayDevice

    // STATE

    readonly property bool available: device !== null
    readonly property bool enabled: available

    readonly property int level: Math.round((device?.percentage ?? 0) * 100)

    readonly property bool charging: device?.state === UPowerDeviceState.Charging

    readonly property real timeToEmpty: device?.timeToEmpty ?? 0
    readonly property real timeToFull: device?.timeToFull ?? 0

    // PRESENTATION

    readonly property int iconLevel: Math.floor(level / 10) * 10

    readonly property string iconName: {
        const suffix = charging ? "-charging-symbolic" : "-symbolic";
        return `battery-level-${iconLevel}${suffix}`;
    }

    readonly property color iconColor: {
        if (!available)
            return Theme.foreground;

        if (charging)
            return Theme.success;

        if (level <= 10)
            return Theme.error;

        if (level <= 30)
            return Theme.warning;

        return Theme.foreground;
    }

    // OSD

    readonly property int warningLevel: {
        if (!available)
            return 0;

        if (charging)
            return 1;

        if ((level <= 20) && !charging)
            return 2;

        if ((level <= 10) && !charging)
            return 3;

        return 0;
    }

    readonly property int osdSignal: warningLevel

    // HELPERS

    function formatTime(seconds: real): string {
        if (seconds <= 0)
            return "";

        const totalMinutes = Math.floor(seconds / 60);
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;

        if (hours > 0)
            return `${hours}h ${minutes}min`;

        return `${minutes}min`;
    }
}

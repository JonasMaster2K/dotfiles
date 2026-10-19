pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../style"

Singleton{
    property bool enabled: false
    readonly property string iconName: enabled ? "airplane-mode-symbolic" : "airplane-mode-disabled-symbolic"
    readonly property color iconColor: enabled ? Theme.warning : Theme.foreground

    function toggleMode(): void{
        enabled ? modeOff.running = true : modeOn.running = true
        enabled = !enabled
    }

    Process {
        id: modeOn
        command: [ "rfkill", "block", "all" ]
    }

    Process {
        id: modeOff
        command: [ "rfkill", "unblock", "all" ]
    }
}
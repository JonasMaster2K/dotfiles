pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    Process {
        id: process

        command: ["hyprctl", "devices", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    const keyboard = data.keyboards.find(k => k.main) ?? data.keyboards[0];

                    if (keyboard)
                        root.active = keyboard.numLock;
                } catch (e) {
                    console.error("CapsLock:", e);
                }
            }
        }
    }

    Timer {
        interval: 300
        running: true
        repeat: true

        onTriggered: {
            if (!process.running)
                process.running = true;
        }
    }

    Component.onCompleted: process.running = true

    readonly property bool osdSignal: active
}

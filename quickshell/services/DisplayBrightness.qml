pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightnessPercent: 0

    readonly property real osdSignal: brightnessPercent

    Process {
        id: process

        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");

                if (fields.length < 5)
                    return;
                const value = parseFloat(fields[3].replace("%", ""));

                if (!isNaN(value))
                    root.brightnessPercent = value;
                console.log(value);
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true

        onTriggered: {
            if (!process.running)
                process.running = true;
        }
    }

    Component.onCompleted: process.running = true
}

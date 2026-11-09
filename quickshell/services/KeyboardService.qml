pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: service

    // =========================================================================
    // CONFIGURATION
    // =========================================================================

    readonly property string ledPath: "/sys/class/leds/samsung-galaxybook::kbd_backlight"

    property int backlight: 0
    property int maxBacklight: 0

    readonly property var osdSignal: backlight

    property int pollInterval: 200

    // =========================================================================
    // UPDATE
    // =========================================================================

    function refresh() {
        if (!reader.running)
            reader.running = true;
    }

    // =========================================================================
    // FILE READER
    // =========================================================================

    Process {
        id: reader

        command: ["bash", "-c", "cat '" + service.ledPath + "/brightness'; cat '" + service.ledPath + "/max_brightness'"]

        stdout: StdioCollector {
            onStreamFinished: {
                const values = text.trim().split("\n");

                if (values.length < 2)
                    return;

                const current = Number(values[0]);
                const maximum = Number(values[1]);

                if (!Number.isFinite(current) || !Number.isFinite(maximum))
                    return;

                service.backlight = current;
                service.maxBacklight = maximum;
            }
        }
    }

    // =========================================================================
    // POLLING
    // =========================================================================

    Timer {
        interval: service.pollInterval
        repeat: true
        running: true

        onTriggered: service.refresh()
    }

    Component.onCompleted: refresh()
}

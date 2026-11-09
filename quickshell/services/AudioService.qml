pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import "../style"

Singleton {
    id: root

    // PIPEWIRE

    readonly property PwNode node: Pipewire.defaultAudioSink
    readonly property PwNodeAudio output: node?.audio ?? null

    PwObjectTracker {
        objects: [root.node]
    }

    // STATE

    readonly property bool available: node !== null && output !== null
    readonly property bool enabled: available

    readonly property real volume: output?.volume ?? 0
    readonly property int volumePercent: Math.round(volume * 100)

    readonly property bool muted: output?.muted ?? true

    // PRESENTATION

    readonly property string iconName: {
        if (muted || volumePercent === 0)
            return "audio-volume-muted-symbolic";

        if (volumePercent < 33)
            return "audio-volume-low-symbolic";

        if (volumePercent < 66)
            return "audio-volume-medium-symbolic";

        return "audio-volume-high-symbolic";
    }

    readonly property color iconColor: {
        if (!available)
            return Theme.foreground;

        if (muted || volumePercent === 0)
            return Theme.warning;

        if (volumePercent >= 90)
            return Theme.error;

        return Theme.foreground;
    }

    // OSD

    readonly property int osdSignal: volumePercent
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import "../style"

Singleton {
    id: root

    // =========================================================================
    // PIPEWIRE
    // =========================================================================

    readonly property PwNode node: Pipewire.defaultAudioSource
    readonly property PwNodeAudio input: node?.audio ?? null

    PwObjectTracker {
        objects: [root.node]
    }

    // =========================================================================
    // STATE
    // =========================================================================

    readonly property bool available: node !== null && input !== null
    readonly property bool enabled: available

    readonly property real volume: (input?.volume ?? 0) * 100
    readonly property int volumePercent: Math.round(volume)

    readonly property bool muted: input?.muted ?? true

    // =========================================================================
    // PRESENTATION
    // =========================================================================

    readonly property string iconName: {
        if (muted)
            return "microphone-sensitivity-muted-symbolic";

        if (volumePercent < 33)
            return "microphone-sensitivity-low-symbolic";

        if (volumePercent < 66)
            return "microphone-sensitivity-medium-symbolic";

        return "microphone-sensitivity-high-symbolic";
    }

    readonly property color iconColor: {
        if (muted)
            return Theme.warning;

        if (volumePercent < 66)
            return Theme.foreground;

        return Theme.error;
    }

    // =========================================================================
    // OSD
    // =========================================================================

    readonly property bool osdSignal: muted
}

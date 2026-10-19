pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import "../style"

Singleton {
    readonly property bool available: true
    readonly property bool enabled: true
    readonly property color iconColor: muted ? Theme.warning : volume == 0 ? Theme.warning : volume < 66 ? Theme.foreground : Theme.error
    readonly property string iconName: "audio-volume-" + (muted ? "muted" : volume <= 0 ? "off" : volume < 33 ? "low" : volume < 66 ? "medium" : "high") + "-symbolic"
    readonly property bool muted: output?.muted ?? false
    readonly property PwNode node: Pipewire.defaultAudioSink
    readonly property PwNodeAudio output: node?.audio ?? null
    readonly property int volume: output?.volume * 100 ?? 0

    PwObjectTracker {
        objects: [node]
    }
}

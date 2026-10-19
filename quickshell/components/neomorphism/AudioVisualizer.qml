import QtQuick
import Quickshell.Io

import "../style"

Item {
    id: root

    enum Origin {
        Top,
        Center,
        Bottom
    }

    property int origin: AudioVisualizer.Center

    property real barSpacing: Theme.audioVisualizerBarSpacing
    property real minimumBarHeight: Theme.audioVisualizerMinimumBarHeight
    property real minimumBarWidth: Theme.audioVisualizerMinimumBarWidth
    property real centerOffset: 0

    property color barColor: Theme.audioVisualizerColor

    property real sensitivity: Theme.audioVisualizerSensitivity
    property real silenceThreshold: Theme.audioVisualizerSilenceThreshold
    property int hideDelay: Theme.audioVisualizerHideDelay

    property bool running: true

    readonly property bool hasAudio: _hasAudio
    readonly property real availableBarWidth: Math.max(0, width - barSpacing * Math.max(0, _barCount - 1))
    readonly property real barWidth: _barCount > 0 ? Math.max(minimumBarWidth, availableBarWidth / _barCount) : 0

    property bool _hasAudio: false
    property var _values: []
    property int _barCount: 0

    implicitWidth: Theme.audioVisualizerWidth
    implicitHeight: Theme.audioVisualizerHeight

    visible: running && _hasAudio
    clip: true

    Process {
        id: cavaProcess

        running: root.running
        command: [
            "cava",
            "-p",
            Qt.resolvedUrl("../config/cava.conf").toString().replace("file://", "")
        ]

        stdout: SplitParser {
            id: cavaParser

            onRead: data => {
                if (!root.running)
                    return

                const parts = data.split(";")
                const count = parts.length > 0 && parts[parts.length - 1] === "" ? parts.length - 1 : parts.length

                if (count <= 0)
                    return

                if (root._barCount !== count) {
                    root._barCount = count

                    const initialValues = new Array(count)

                    for (let index = 0; index < count; ++index)
                        initialValues[index] = 0

                    root._values = initialValues
                }

                const values = new Array(count)
                const scale = root.sensitivity / 1000
                let audioDetected = false

                for (let index = 0; index < count; ++index) {
                    let value = Number(parts[index]) * scale

                    if (!isFinite(value))
                        value = 0

                    value = Math.max(0, Math.min(1, value))
                    values[index] = value

                    if (value > root.silenceThreshold)
                        audioDetected = true
                }

                root._values = values

                if (audioDetected) {
                    if (silenceTimer.running)
                        silenceTimer.stop()

                    root._hasAudio = true
                    return
                }

                if (root.hideDelay <= 0) {
                    silenceTimer.stop()
                    root._hasAudio = false
                } else if (!silenceTimer.running) {
                    silenceTimer.start()
                }
            }
        }
    }

    Timer {
        id: silenceTimer

        interval: Math.max(1, root.hideDelay)
        repeat: false

        onTriggered: root._hasAudio = false
    }

    Row {
        id: barRow

        anchors.fill: parent

        spacing: root.barSpacing

        Repeater {
            id: barRepeater

            model: root._barCount

            delegate: Rectangle {
                id: bar

                required property int index

                readonly property real audioValue: index < root._values.length ? root._values[index] : 0
                readonly property real maximumHeight: root.origin === AudioVisualizer.Center ? root.height * 0.9 : root.height

                width: root.barWidth
                height: Math.min(maximumHeight, Math.max(root.minimumBarHeight, maximumHeight * audioValue))

                y: {
                    switch (root.origin) {
                    case AudioVisualizer.Top:
                        return 0
                    case AudioVisualizer.Center:
                        return root.height * 0.5 - height * 0.5 + root.centerOffset
                    case AudioVisualizer.Bottom:
                        return root.height - height
                    default:
                        return root.height - height
                    }
                }

                radius: Math.min(width * 0.5, height * 0.5)
                color: root.barColor
            }
        }
    }

    onRunningChanged: {
        if (running)
            return

        silenceTimer.stop()

        _hasAudio = false
        _values = []
        _barCount = 0
    }
}
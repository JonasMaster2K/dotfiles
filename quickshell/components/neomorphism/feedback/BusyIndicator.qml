import QtQuick
import "../../../style"
import "../../../config"

Item {
    id: root

    property string sizeVariant: "md"
    property bool running: true
    property color accentColor: Colors.accent
    property color trackColor: Colors.surfacePressed
    property real strokeWidth: Math.max(3 * Settings.scale, width * 0.12)

    readonly property real diameter: {
        switch (sizeVariant) {
        case "xs": return 20 * Settings.scale
        case "sm": return 28 * Settings.scale
        case "lg": return 48 * Settings.scale
        case "xl": return 64 * Settings.scale
        default: return 36 * Settings.scale
        }
    }
    implicitWidth: diameter
    implicitHeight: diameter
    visible: running

    Canvas {
        id: spinner
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const radius = Math.max(0, Math.min(width, height) / 2 - root.strokeWidth);
            ctx.lineWidth = root.strokeWidth;
            ctx.lineCap = "round";
            ctx.strokeStyle = root.trackColor.toString();
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, radius, 0, Math.PI * 2);
            ctx.stroke();
            ctx.strokeStyle = root.accentColor.toString();
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, radius, -Math.PI / 2, Math.PI / 4);
            ctx.stroke();
        }
        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
            running: root.running && root.visible
        }
        Connections {
            target: root
            function onAccentColorChanged() { spinner.requestPaint(); }
            function onTrackColorChanged() { spinner.requestPaint(); }
            function onStrokeWidthChanged() { spinner.requestPaint(); }
        }
    }
}

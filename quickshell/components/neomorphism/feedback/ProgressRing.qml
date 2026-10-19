import QtQuick
import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: root

    property string sizeVariant: "md"
    property real from: 0
    property real to: 100
    property real value: 65
    property real strokeWidth: Math.max(3 * Settings.scale, width * 0.11)
    property bool showValue: true
    property string valueSuffix: "%"
    property string elevation: "sunken"
    property color accentColor: Colors.accent
    property color trackColor: Colors.surfacePressed
    readonly property real progress: to === from ? 0 : Math.max(0, Math.min(1, (value - from) / (to - from)))

    readonly property real diameter: {
        switch (sizeVariant) {
        case "xs": return 38 * Settings.scale
        case "sm": return 52 * Settings.scale
        case "lg": return 104 * Settings.scale
        case "xl": return 136 * Settings.scale
        default: return 76 * Settings.scale
        }
    }
    implicitWidth: diameter
    implicitHeight: diameter

    Surfaces.Surface {
        anchors.fill: parent
        elevation: root.elevation
        borderSize: 1 * Settings.scale
        cornerRadius: Math.min(width, height) / 2
        surfaceColor: Colors.surface
    }

    Canvas {
        id: ringCanvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.max(0, Math.min(width, height) / 2 - root.strokeWidth * 1.4);
            ctx.lineWidth = root.strokeWidth;
            ctx.lineCap = "round";
            ctx.strokeStyle = root.trackColor.toString();
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
            ctx.stroke();
            if (root.progress > 0) {
                ctx.strokeStyle = root.accentColor.toString();
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + root.progress * Math.PI * 2);
                ctx.stroke();
            }
        }
        Connections {
            target: root
            function onProgressChanged() { ringCanvas.requestPaint(); }
            function onAccentColorChanged() { ringCanvas.requestPaint(); }
            function onTrackColorChanged() { ringCanvas.requestPaint(); }
            function onStrokeWidthChanged() { ringCanvas.requestPaint(); }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.showValue
        text: Math.round(root.progress * 100) + root.valueSuffix
        color: Colors.textPrimary
        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.labelSize
        font.weight: Font.DemiBold
    }
}

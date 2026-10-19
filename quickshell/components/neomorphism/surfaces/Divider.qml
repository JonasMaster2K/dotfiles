import QtQuick

import "../../../style"
import "../../../config"

Item {
    id: control

    property int orientation: Qt.Horizontal
    property real thickness: Math.max(1, Settings.scale)
    property real lineInset: 0
    property bool showHighlight: true
    property color lineColor: Colors.shadowDark
    property color highlightColor: Colors.shadowLight

    readonly property bool horizontal: orientation === Qt.Horizontal

    implicitWidth: horizontal ? 160 * Settings.scale : thickness * (showHighlight ? 2 : 1)
    implicitHeight: horizontal ? thickness * (showHighlight ? 2 : 1) : 80 * Settings.scale

    Rectangle {
        x: control.horizontal ? control.lineInset : 0
        y: 0
        width: control.horizontal ? Math.max(0, control.width - control.lineInset * 2) : control.thickness
        height: control.horizontal ? control.thickness : Math.max(0, control.height - control.lineInset * 2)
        color: control.lineColor
        radius: control.thickness / 2
        opacity: 0.55
        visible: width > 0 && height > 0
        anchors.verticalCenter: control.horizontal ? undefined : parent.verticalCenter
    }

    Rectangle {
        visible: control.showHighlight
        x: control.horizontal ? control.lineInset : control.thickness
        y: control.horizontal ? control.thickness : 0
        width: control.horizontal ? Math.max(0, control.width - control.lineInset * 2) : control.thickness
        height: control.horizontal ? control.thickness : Math.max(0, control.height - control.lineInset * 2)
        color: control.highlightColor
        radius: control.thickness / 2
        opacity: 0.75
        anchors.verticalCenter: control.horizontal ? undefined : parent.verticalCenter
    }
}

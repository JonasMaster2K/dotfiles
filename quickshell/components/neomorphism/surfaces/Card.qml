import QtQuick

import "../../../style"
import "../../../config"

Item {
    id: control

    // Child elements declared inside Card are placed in the content area.
    default property alias content: contentHost.data

    property string elevation: "raised"
    property color surfaceColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surfacePressed
    property bool hovered: false

    property real cornerRadius: Dimensions.radiusButton
    property real borderSize: Dimensions.borderWidth
    property real contentPadding: Dimensions.spacingXl
    property real shadowOffset: Dimensions.shadowOffsetSm
    property real shadowRadius: Dimensions.shadowRadiusSm

    implicitWidth: 260 * Settings.scale
    implicitHeight: 160 * Settings.scale

    Surface {
        anchors.fill: parent
        elevation: control.elevation
        surfaceColor: control.surfaceColor
        hoverColor: control.hoverColor
        pressedColor: control.pressedColor
        hovered: control.hovered
        cornerRadius: control.cornerRadius
        borderSize: control.borderSize
        shadowOffset: control.shadowOffset
        shadowRadius: control.shadowRadius
    }

    Item {
        id: contentHost
        anchors.fill: parent
        anchors.margins: control.contentPadding
    }
}

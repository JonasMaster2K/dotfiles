import QtQuick
import Qt5Compat.GraphicalEffects as Effects

import Quickshell
import Quickshell.Widgets

import "../../../style"

Item {
    id: root

    // =========================================================================
    // SOURCE
    // =========================================================================

    property string iconName: ""
    property string fallbackIcon: "application-x-executable"

    // =========================================================================
    // APPEARANCE
    // =========================================================================

    property real size: Dimensions.iconSizeMd

    property color iconColor: Colors.textPrimary
    property bool colorize: true

    // =========================================================================
    // POSITION
    // =========================================================================

    property real xOffset: 0
    property real yOffset: 0

    // =========================================================================
    // INTERNAL
    // =========================================================================

    readonly property string effectiveIconName: iconName.length > 0 ? iconName : fallbackIcon

    // =========================================================================
    // LAYOUT
    // =========================================================================

    implicitWidth: size
    implicitHeight: size

    // =========================================================================
    // ICON
    // =========================================================================

    Item {
        id: iconContainer

        anchors.centerIn: parent

        width: Math.min(root.size, root.width)
        height: Math.min(root.size, root.height)

        x: (root.width - width) / 2 + root.xOffset
        y: (root.height - height) / 2 + root.yOffset

        IconImage {
            id: sourceIcon

            anchors.fill: parent

            source: Quickshell.iconPath(root.effectiveIconName)
            implicitSize: root.size

            smooth: true
            visible: !root.colorize
        }

        Effects.ColorOverlay {
            anchors.fill: sourceIcon

            source: sourceIcon
            color: root.iconColor

            cached: false
            visible: root.colorize
        }
    }
}

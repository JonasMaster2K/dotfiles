pragma ComponentBehavior: Bound

import QtQuick

import "../../../style"
import "../images"

Item {
    id: root

    // =========================================================================
    // SOURCE
    // =========================================================================

    required property var source

    // =========================================================================
    // APPEARANCE
    // =========================================================================

    property real size: Dimensions.iconSizeMd
    property real radius: Dimensions.radiusSm

    property color iconColor: Colors.textPrimary
    property bool colorize: false

    // =========================================================================
    // INTERNAL
    // =========================================================================

    readonly property string sourceString: source === null || source === undefined ? "" : String(source)

    readonly property bool isImageSource: /^(https?:|file:|image:|data:|qrc:|\/)/i.test(sourceString)

    // =========================================================================
    // LAYOUT
    // =========================================================================

    implicitWidth: size
    implicitHeight: size

    // =========================================================================
    // CONTENT
    // =========================================================================

    Loader {
        id: iconLoader

        anchors.fill: parent

        sourceComponent: root.isImageSource ? imageComponent : iconComponent
    }

    // -------------------------------------------------------------------------
    // Image
    // -------------------------------------------------------------------------

    Component {
        id: imageComponent

        URLImage {
            anchors.fill: parent

            source: root.sourceString
            coverSize: root.size
            radius: root.radius
        }
    }

    // -------------------------------------------------------------------------
    // System Icon
    // -------------------------------------------------------------------------

    Component {
        id: iconComponent

        Icon {
            anchors.fill: parent

            iconName: root.sourceString
            size: root.size

            iconColor: root.iconColor
            colorize: root.colorize
        }
    }
}

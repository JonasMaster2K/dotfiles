pragma ComponentBehavior: Bound

import QtQuick

import "../../../style"
import "../../../config"

Item {
    id: control

    // =========================================================================
    // PUBLIC API
    // =========================================================================

    property bool expanded: false
    property bool revealOnHover: true
    property bool interactive: true
    property real customWidth: 0
    property real customHeight: 0

    // left | right | up | down
    property string direction: "left"

    property string elevation: "raised"
    property real cornerRadius: Dimensions.radiusControl
    property color surfaceColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surface
    property real contentSpacing: Dimensions.spacingXs
    property real contentPadding: 0
    property int animationDuration: Animations.animationFast
    property bool animateColors: true
    property alias triggerContent: triggerContainer.data
    property alias revealedContent: revealedContainer.data
    readonly property bool horizontal: direction === "left" || direction === "right"
    readonly property bool open: expanded || (interactive && revealOnHover && hoverHandler.hovered)

    // =========================================================================
    // CONTENT GEOMETRY
    // =========================================================================
    readonly property real triggerWidth: Math.max(0, triggerContainer.childrenRect.width)
    readonly property real triggerHeight: Math.max(0, triggerContainer.childrenRect.height)
    readonly property real revealedWidth: Math.max(0, revealedContainer.childrenRect.width)
    readonly property real revealedHeight: Math.max(0, revealedContainer.childrenRect.height)
    readonly property bool hasRevealedContent: revealedWidth > 0 && revealedHeight > 0
    readonly property real revealGap: hasRevealedContent ? contentSpacing : 0
    readonly property real collapsedWidth: triggerWidth + 2 * contentPadding
    readonly property real collapsedHeight: triggerHeight + 2 * contentPadding
    readonly property real expandedWidth: (horizontal ? triggerWidth + revealGap + revealedWidth : Math.max(triggerWidth, revealedWidth)) + 2 * contentPadding
    readonly property real expandedHeight: (horizontal ? Math.max(triggerHeight, revealedHeight) : triggerHeight + revealGap + revealedHeight) + 2 * contentPadding

    readonly property real defaultWidth: open ? expandedWidth : collapsedWidth
    readonly property real defaultHeight: open ? expandedHeight : collapsedHeight

    implicitWidth: customWidth > 0 ? Math.max(customWidth, open ? expandedWidth : collapsedWidth) : defaultWidth

    implicitHeight: customHeight > 0 ? Math.max(customHeight, open ? expandedHeight : collapsedHeight) : defaultHeight
    clip: false

    Behavior on implicitWidth {
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    // =========================================================================
    // HOVER
    // =========================================================================

    HoverHandler {
        id: hoverHandler
        enabled: control.interactive && control.revealOnHover
    }

    // =========================================================================
    // BACKGROUND SURFACE
    // =========================================================================

    Surface {
        id: backgroundSurface

        anchors.fill: parent

        elevation: control.elevation
        cornerRadius: control.cornerRadius

        surfaceColor: control.surfaceColor
        hoverColor: control.hoverColor
        pressedColor: control.pressedColor

        hovered: control.open
        animateColors: control.animateColors
    }

    // =========================================================================
    // REVEALED CONTENT
    // =========================================================================

    Item {
        id: revealedContainer

        width: childrenRect.width
        height: childrenRect.height

        x: {
            switch (control.direction) {
            case "left":
                return triggerContainer.x - control.contentSpacing - width;
            case "right":
                return triggerContainer.x + triggerContainer.width + control.contentSpacing;
            default:
                return (control.width - width) / 2;
            }
        }

        y: {
            switch (control.direction) {
            case "up":
                return triggerContainer.y - control.contentSpacing - height;
            case "down":
                return triggerContainer.y + triggerContainer.height + control.contentSpacing;
            default:
                return (control.height - height) / 2;
            }
        }

        opacity: control.open ? 1 : 0
        enabled: control.open
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    // =========================================================================
    // TRIGGER CONTENT
    // =========================================================================

    Item {
        id: triggerContainer

        width: childrenRect.width
        height: childrenRect.height

        x: {
            switch (control.direction) {
            case "left":
                return control.width - control.contentPadding - width;
            case "right":
                return control.contentPadding;
            default:
                return (control.width - width) / 2;
            }
        }

        y: {
            switch (control.direction) {
            case "up":
                return control.height - control.contentPadding - height;
            case "down":
                return control.contentPadding;
            default:
                return (control.height - height) / 2;
            }
        }
    }
}

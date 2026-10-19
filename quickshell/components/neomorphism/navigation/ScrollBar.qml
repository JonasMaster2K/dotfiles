import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.ScrollBar {
    id: control

    // ---------------------------------------------------------------------
    // Public API
    // ---------------------------------------------------------------------

    property string sizeVariant: "sm"

    property bool showTrack: false
    property bool autoHide: true
    property bool viewHovered: false
    property bool animateColors: true

    // Gesamtdicke der Scrollbar.
    property real thickness: {
        switch (sizeVariant) {
        case "xs":
            return 6 * Settings.scale;
        case "sm":
            return 10 * Settings.scale;
        case "lg":
            return 14 * Settings.scale;
        case "xl":
            return 16 * Settings.scale;
        default:
            return 12 * Settings.scale;
        }
    }

    // Gleicher Innenabstand für Track und Thumb.
    property real inset: 1 * Settings.scale

    property real minThumbSize: Dimensions.hitTargetMin

    property color trackColor: Colors.surface
    property color trackHoverColor: Colors.surfaceHover

    property color thumbColor: Colors.surfaceRaised
    property color thumbHoverColor: Colors.surfaceHover
    property color thumbPressedColor: Colors.surfacePressed

    property color shadowColor: Colors.shadowDark
    property color highlightColor: Colors.shadowLight

    property int fadeDuration: Animations.animationNormal

    // ---------------------------------------------------------------------
    // Geometry
    // ---------------------------------------------------------------------

    readonly property real axisLength: vertical ? height : width

    readonly property real safeInset: Math.min(Math.max(0, inset), Math.max(0, thickness / 2 - 1))

    hoverEnabled: true
    interactive: true

    implicitWidth: vertical ? thickness : 0
    implicitHeight: vertical ? 0 : thickness

    minimumSize: axisLength > 0 ? Math.min(1, minThumbSize / axisLength) : 0

    // ---------------------------------------------------------------------
    // Visibility
    // ---------------------------------------------------------------------

    // Die Policy entscheidet, ob die Scrollbar überhaupt gebraucht wird.
    // autoHide entscheidet nur, ob eine benötigte Scrollbar verblasst.
    visible: policy !== Controls.ScrollBar.AlwaysOff && (policy === Controls.ScrollBar.AlwaysOn || size < 0.999)

    readonly property bool shouldShow: !autoHide || viewHovered || hovered || active || pressed

    opacity: shouldShow ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: control.fadeDuration
            easing.type: Easing.InOutCubic
        }
    }

    // ---------------------------------------------------------------------
    // Track
    // ---------------------------------------------------------------------

    background: Item {
        implicitWidth: control.thickness
        implicitHeight: control.thickness

        Surfaces.Surface {
            anchors.fill: parent

            // Gleicher Abstand wie beim Thumb.
            anchors.margins: control.safeInset

            visible: control.showTrack

            elevation: "sunken"
            cornerRadius: Dimensions.radiusPill

            surfaceColor: control.trackColor
            hoverColor: control.trackHoverColor

            hovered: control.hovered && control.enabled
            animateColors: control.animateColors

            shadowDarkColor: control.shadowColor
            shadowLightColor: control.highlightColor
        }
    }

    // ---------------------------------------------------------------------
    // Thumb
    // ---------------------------------------------------------------------

    contentItem: Item {
        implicitWidth: control.thickness
        implicitHeight: control.thickness

        Surfaces.Surface {
            anchors.fill: parent

            // Gleicher Abstand wie beim Track.
            anchors.margins: control.safeInset

            elevation: "raised"
            cornerRadius: Dimensions.radiusPill

            surfaceColor: control.pressed ? control.thumbPressedColor : control.thumbColor

            hoverColor: control.thumbHoverColor
            pressedColor: control.thumbPressedColor

            hovered: control.hovered && control.enabled
            animateColors: control.animateColors

            shadowDarkColor: control.shadowColor
            shadowLightColor: control.highlightColor
        }
    }
}

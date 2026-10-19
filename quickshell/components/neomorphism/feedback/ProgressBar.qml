import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.ProgressBar {
    id: control

    // =========================================================================
    // PROPERTIES
    // =========================================================================

    property string sizeVariant: "md"
    property string elevation: "sunken"

    property bool showValue: false
    property string valueSuffix: "%"

    property color accentColor: Colors.accent

    property real borderSize: 1 * Settings.scale
    property real cornerRadius: height / 2

    // =========================================================================
    // SIZES
    // =========================================================================

    readonly property real trackHeight: {
        switch (sizeVariant) {
        case "xs":
            return 6 * Settings.scale;
        case "sm":
            return 9 * Settings.scale;
        case "lg":
            return 17 * Settings.scale;
        case "xl":
            return 22 * Settings.scale;
        default:
            return 13 * Settings.scale;
        }
    }

    readonly property real innerWidth: Math.max(0, width - 2 * borderSize)

    readonly property real innerHeight: Math.max(0, trackHeight - 2 * borderSize)

    implicitWidth: 220 * Settings.scale

    implicitHeight: trackHeight + (showValue ? Dimensions.spacingLg + valueLabel.implicitHeight : 0)

    // =========================================================================
    // BACKGROUND
    // =========================================================================

    background: Surfaces.Surface {
        x: 0
        y: 0

        width: control.width
        height: control.trackHeight

        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius

        surfaceColor: Colors.surface
    }

    // =========================================================================
    // CONTENT
    // =========================================================================

    contentItem: Item {
        id: progressContent

        // ---------------------------------------------------------------------
        // NORMAL PROGRESS FILL
        // ---------------------------------------------------------------------

        Rectangle {
            id: fill

            visible: !control.indeterminate

            x: control.borderSize
            y: control.borderSize

            width: control.innerWidth * control.visualPosition
            height: control.innerHeight

            radius: height / 2
            color: control.accentColor

            Behavior on width {
                enabled: !control.indeterminate

                NumberAnimation {
                    duration: Animations.animationFast
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ---------------------------------------------------------------------
        // INDETERMINATE PROGRESS FILL
        //
        // No OpacityMask or clipping texture.
        // The segment shrinks when entering/leaving the track.
        // ---------------------------------------------------------------------

        Rectangle {
            id: busyFill

            visible: control.indeterminate

            readonly property real trackWidth: control.innerWidth
            readonly property real segmentWidth: trackWidth * 0.3

            property real progress: 0

            readonly property real segmentStart: progress * (trackWidth + segmentWidth) - segmentWidth

            readonly property real segmentEnd: segmentStart + segmentWidth

            readonly property real visibleStart: Math.max(0, segmentStart)

            readonly property real visibleEnd: Math.min(trackWidth, segmentEnd)

            x: control.borderSize + visibleStart
            y: control.borderSize

            width: Math.max(0, visibleEnd - visibleStart)
            height: control.innerHeight

            radius: Math.min(height / 2, width / 2)
            color: control.accentColor

            SequentialAnimation on progress {
                running: control.indeterminate && control.visible && control.width > 0

                loops: Animation.Infinite

                NumberAnimation {
                    from: 0
                    to: 1
                    duration: 1250
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    // =========================================================================
    // VALUE LABEL
    // =========================================================================

    Text {
        id: valueLabel

        visible: control.showValue && !control.indeterminate

        anchors.top: parent.top
        anchors.topMargin: control.trackHeight + Dimensions.spacingSm

        anchors.horizontalCenter: parent.horizontalCenter

        text: Math.round(control.position * 100) + control.valueSuffix

        color: Colors.textSecondary

        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.labelSize
    }

    // =========================================================================
    // DISABLED STATE
    // =========================================================================

    opacity: enabled ? 1 : 0.45
}

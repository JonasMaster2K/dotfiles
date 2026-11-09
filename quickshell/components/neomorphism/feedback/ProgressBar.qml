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
    property real valueSpacing: Dimensions.spacingSm * Settings.scale

    property string orientation: "horizontal"
    property string valuePosition: "end"

    readonly property bool vertical: orientation === "vertical"

    // =========================================================================
    // DIMENSIONS
    // =========================================================================

    readonly property real defaultThickness: {
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

    property real length: 220 * Settings.scale
    property real thickness: defaultThickness

    // =========================================================================
    // LABEL SIZE
    // =========================================================================

    readonly property real valueWidth: showValue ? valueLabel.implicitWidth : 0

    readonly property real valueHeight: showValue ? valueLabel.implicitHeight : 0

    readonly property real labelOffset: showValue && valuePosition !== "center" ? valueSpacing : 0

    // =========================================================================
    // COMPONENT SIZE
    // =========================================================================

    readonly property real baseWidth: vertical ? thickness : length
    readonly property real baseHeight: vertical ? length : thickness

    readonly property real extraWidth: showValue && ((!vertical && valuePosition !== "center") || (vertical && valuePosition === "center")) ? valueWidth + valueSpacing : 0

    readonly property real extraHeight: showValue && ((vertical && valuePosition !== "center") || (!vertical && valuePosition === "center")) ? valueHeight + valueSpacing : 0

    implicitWidth: baseWidth + extraWidth
    implicitHeight: baseHeight + extraHeight

    width: implicitWidth
    height: implicitHeight

    // =========================================================================
    // TRACK GEOMETRY
    // =========================================================================

    readonly property real trackWidth: vertical ? thickness : length

    readonly property real trackHeight: vertical ? length : thickness

    readonly property real trackX: vertical ? (width - trackWidth) / 2 : showValue && valuePosition === "start" ? valueWidth + valueSpacing : 0

    readonly property real trackY: vertical && showValue && valuePosition === "start" ? valueHeight + valueSpacing : 0

    readonly property real innerTrackWidth: Math.max(0, trackWidth - 2 * borderSize)

    readonly property real innerTrackHeight: Math.max(0, trackHeight - 2 * borderSize)

    readonly property real effectiveCornerRadius: Math.min(trackWidth, trackHeight) / 2

    // =========================================================================
    // BACKGROUND
    // =========================================================================

    background: Surfaces.Surface {
        x: control.trackX
        y: control.trackY

        width: control.trackWidth
        height: control.trackHeight

        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.effectiveCornerRadius

        surfaceColor: Colors.surface
    }

    // =========================================================================
    // CONTENT
    // =========================================================================

    contentItem: Item {
        id: progressContent

        // ---------------------------------------------------------------------
        // NORMAL PROGRESS
        // ---------------------------------------------------------------------

        Rectangle {
            id: fill

            visible: !control.indeterminate

            x: control.trackX + control.borderSize

            y: control.vertical ? control.trackY + control.borderSize + control.innerTrackHeight - height : control.trackY + control.borderSize

            width: control.vertical ? control.innerTrackWidth : control.innerTrackWidth * control.position

            height: control.vertical ? control.innerTrackHeight * control.position : control.innerTrackHeight

            radius: Math.min(width, height) / 2
            color: control.accentColor

            Behavior on width {
                enabled: !control.vertical

                NumberAnimation {
                    duration: Animations.animationFast
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on height {
                enabled: control.vertical

                NumberAnimation {
                    duration: Animations.animationFast
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ---------------------------------------------------------------------
        // INDETERMINATE PROGRESS
        // ---------------------------------------------------------------------

        Item {
            id: busyTrack

            visible: control.indeterminate

            x: control.trackX + control.borderSize
            y: control.trackY + control.borderSize

            width: control.innerTrackWidth
            height: control.innerTrackHeight

            clip: true

            Rectangle {
                id: busyFill

                property real progress: 0

                readonly property real availableLength: control.vertical ? busyTrack.height : busyTrack.width

                readonly property real segmentLength: availableLength * 0.3

                width: control.vertical ? busyTrack.width : segmentLength

                height: control.vertical ? segmentLength : busyTrack.height

                x: control.vertical ? 0 : progress * (availableLength + segmentLength) - segmentLength

                y: control.vertical ? availableLength - progress * (availableLength + segmentLength) : 0

                radius: Math.min(width, height)
                color: control.accentColor

                SequentialAnimation on progress {
                    running: control.indeterminate && control.visible && busyTrack.width > 0 && busyTrack.height > 0

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
    }

    // =========================================================================
    // VALUE LABEL
    // =========================================================================

    Text {
        id: valueLabel

        visible: control.showValue && !control.indeterminate

        x: {
            if (control.vertical)
                return (control.width - width) / 2;

            switch (control.valuePosition) {
            case "start":
                return 0;
            case "end":
                return control.width - width;
            default:
                return (control.width - width) / 2;
            }
        }

        y: {
            if (control.vertical) {
                switch (control.valuePosition) {
                case "start":
                    return 0;
                case "end":
                    return control.trackY + control.trackHeight + control.valueSpacing;
                default:
                    return (control.height - height) / 2;
                }
            }

            if (control.valuePosition === "center")
                return control.trackY + control.trackHeight + control.valueSpacing;

            return (control.height - height) / 2;
        }

        text: Math.round(control.position * 100) + control.valueSuffix

        color: Colors.textSecondary

        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.labelSize * Settings.scale

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // =========================================================================
    // DISABLED STATE
    // =========================================================================

    opacity: enabled ? 1 : 0.45
}

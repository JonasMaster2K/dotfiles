pragma ComponentBehavior: Bound

import QtQuick

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: control

    // =========================================================================
    // PROPERTIES
    // =========================================================================

    property int from: 0
    property int to: 4
    property int value: 0

    property string sizeVariant: "md"
    property string elevation: "sunken"

    property color accentColor: Colors.accent

    property real borderSize: 1 * Settings.scale
    property real segmentSpacing: Dimensions.spacingXs * Settings.scale

    property string orientation: "horizontal"

    readonly property bool vertical: orientation === "vertical"

    readonly property int segmentCount: Math.max(0, to - from)

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

    implicitWidth: vertical ? thickness : length
    implicitHeight: vertical ? length : thickness

    width: implicitWidth
    height: implicitHeight

    // =========================================================================
    // SEGMENT GEOMETRY
    // =========================================================================

    readonly property real segmentLength: segmentCount > 0 ? Math.max(0, (length - (segmentCount - 1) * segmentSpacing) / segmentCount) : 0

    readonly property real effectiveCornerRadius: thickness / 2

    readonly property int activeSegments: Math.max(0, Math.min(segmentCount, value - from))

    opacity: enabled ? 1 : 0.45

    // =========================================================================
    // HORIZONTAL SEGMENTS
    // =========================================================================

    Row {
        anchors.fill: parent
        spacing: control.segmentSpacing

        visible: !control.vertical

        Repeater {
            model: control.segmentCount

            delegate: Item {
                required property int index

                width: control.segmentLength
                height: control.thickness

                readonly property bool active: index < control.activeSegments

                Surfaces.Surface {
                    id: horizontalSegmentSurface

                    anchors.fill: parent

                    elevation: control.elevation
                    borderSize: control.borderSize
                    cornerRadius: control.effectiveCornerRadius

                    surfaceColor: Colors.surface
                }

                Rectangle {
                    anchors.fill: horizontalSegmentSurface

                    radius: control.effectiveCornerRadius

                    color: control.accentColor

                    opacity: parent.active ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Animations.animationFast
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // VERTICAL SEGMENTS
    // =========================================================================

    Column {
        anchors.fill: parent
        spacing: control.segmentSpacing

        visible: control.vertical

        Repeater {
            model: control.segmentCount

            delegate: Item {
                required property int index

                width: control.thickness
                height: control.segmentLength

                readonly property bool active: index >= control.segmentCount - control.activeSegments

                Surfaces.Surface {
                    id: verticalSegmentSurface

                    anchors.fill: parent

                    elevation: control.elevation
                    borderSize: control.borderSize
                    cornerRadius: control.effectiveCornerRadius

                    surfaceColor: Colors.surface
                }

                Rectangle {
                    anchors.fill: verticalSegmentSurface

                    radius: control.effectiveCornerRadius

                    color: control.accentColor

                    opacity: parent.active ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Animations.animationFast
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}

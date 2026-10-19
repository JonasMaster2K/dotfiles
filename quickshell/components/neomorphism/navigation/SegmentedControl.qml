pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: root

    // ========================================================================
    // PUBLIC API
    // ========================================================================

    property var model: []
    property int currentIndex: 0
    property string sizeVariant: "md"

    property color backgroundColor: Colors.surface
    property color activeColor: Colors.surfaceRaised
    property color inactiveColor: Colors.surfaceSunken
    property color hoverColor: Colors.surfaceHover

    property color textColor: Colors.textPrimary
    property color activeTextColor: Colors.textPrimary

    property bool interactive: true
    property bool animateColors: true

    property real segmentGap: Dimensions.spacingXs

    signal selected(int index)

    // ========================================================================
    // GEOMETRY
    // ========================================================================

    readonly property real controlHeight: {
        switch (sizeVariant) {
        case "xs":
            return Dimensions.controlHeightXs;
        case "sm":
            return Dimensions.controlHeightSm;
        case "lg":
            return Dimensions.controlHeightLg;
        case "xl":
            return Dimensions.controlHeightXl;
        default:
            return Dimensions.controlHeightMd;
        }
    }

    readonly property int segmentCount: model ? model.length : 0

    readonly property real inset: 3 * Settings.scale

    readonly property real segmentWidth: Math.max(0, (width - 2 * inset - Math.max(0, segmentCount - 1) * segmentGap) / Math.max(1, segmentCount))

    implicitWidth: segmentCount * 72 * Settings.scale + Math.max(0, segmentCount - 1) * segmentGap + 2 * inset

    implicitHeight: controlHeight

    // ========================================================================
    // RAISED BACKGROUND
    // ========================================================================

    Surfaces.Surface {
        anchors.fill: parent

        elevation: "raised"
        cornerRadius: Dimensions.radiusPill

        surfaceColor: root.backgroundColor
        hoverColor: root.backgroundColor

        animateColors: root.animateColors
    }

    // ========================================================================
    // FLAT SEGMENTS
    // ========================================================================

    Row {
        id: segmentRow

        anchors.fill: parent
        anchors.margins: root.inset

        spacing: root.segmentGap

        Repeater {
            model: root.segmentCount

            delegate: Controls.AbstractButton {
                id: segment

                required property int index

                readonly property bool selectedState: index === root.currentIndex

                readonly property bool first: index === 0

                readonly property bool last: index === root.segmentCount - 1

                readonly property bool only: root.segmentCount === 1

                width: root.segmentWidth
                height: segmentRow.height

                enabled: root.interactive
                hoverEnabled: true
                focusPolicy: Qt.StrongFocus

                // ============================================================
                // SEGMENT BACKGROUND
                // ============================================================

                background: Item {
                    clip: true

                    Surfaces.Surface {
                        width: segment.only ? parent.width : (segment.first || segment.last) ? parent.width * 2 : parent.width

                        height: parent.height

                        x: segment.last && !segment.only ? parent.width - width : 0

                        y: 0

                        elevation: "flat"

                        cornerRadius: segment.first || segment.last || segment.only ? Dimensions.radiusPill : 0

                        // Flat verwendet pressedColor als Füllfarbe.
                        pressedColor: segment.selectedState ? root.activeColor : root.inactiveColor

                        hoverColor: segment.selectedState ? root.activeColor : root.hoverColor

                        hovered: segment.hovered && segment.enabled

                        animateColors: root.animateColors
                    }
                }

                // ============================================================
                // LABEL
                // ============================================================

                contentItem: Text {
                    text: String(root.model[segment.index])

                    color: segment.selectedState ? root.activeTextColor : root.textColor

                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Typography.labelSize
                    font.bold: segment.selectedState

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    elide: Text.ElideRight

                    leftPadding: 5 * Settings.scale
                    rightPadding: 5 * Settings.scale
                }

                // ============================================================
                // INTERACTION
                // ============================================================

                onClicked: {
                    if (root.currentIndex === index)
                        return;

                    root.currentIndex = index;
                    root.selected(index);
                }
            }
        }
    }
}

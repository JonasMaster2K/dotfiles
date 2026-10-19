pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: root

    // ========================================================================
    // PUBLIC API
    // ========================================================================

    property bool enabledLeft: true
    property bool enabledRight: true

    property alias leftButton: leftButton
    property alias rightButtonBackground: rightButton

    property alias leftContent: leftContent.data
    property alias rightContent: rightContent.data

    property real padding: Dimensions.spacingSm
    property real segmentGap: Dimensions.spacingXs

    property string sizeVariant: "md"

    property color background: Colors.surface
    property color buttonColor: Colors.surfaceSunken
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surfacePressed

    property bool animateColors: true

    signal clickLeft
    signal clickRight

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

    readonly property real inset: 3 * Settings.scale

    implicitWidth: Math.max(2 * controlHeight + segmentGap + 2 * inset, layout.implicitWidth + 2 * inset)

    implicitHeight: Math.max(controlHeight, layout.implicitHeight + 2 * inset)

    // ========================================================================
    // RAISED BACKGROUND
    // ========================================================================

    Surfaces.Surface {
        anchors.fill: parent

        elevation: "raised"
        cornerRadius: Dimensions.radiusPill

        surfaceColor: root.background
        hoverColor: root.background

        animateColors: root.animateColors
    }

    // ========================================================================
    // SEGMENTS
    // ========================================================================

    RowLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: root.inset

        spacing: root.segmentGap

        // ====================================================================
        // LEFT BUTTON
        // ====================================================================

        Controls.AbstractButton {
            id: leftButton

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: 1

            enabled: root.enabledLeft
            hoverEnabled: true
            focusPolicy: Qt.StrongFocus

            implicitWidth: Math.max(root.controlHeight, leftContent.implicitWidth + 2 * root.padding)

            implicitHeight: Math.max(root.controlHeight - 2 * root.inset, leftContent.implicitHeight + 2 * root.padding)

            background: Item {
                clip: true

                Surfaces.Surface {
                    width: parent.width * 2
                    height: parent.height

                    x: 0
                    y: 0

                    elevation: "flat"
                    cornerRadius: Dimensions.radiusPill

                    // Flat verwendet pressedColor als Grundfarbe.
                    pressedColor: leftButton.down ? root.pressedColor : root.buttonColor

                    hoverColor: root.hoverColor
                    hovered: leftButton.hovered && !leftButton.down && leftButton.enabled

                    animateColors: root.animateColors
                }
            }

            contentItem: Item {
                Item {
                    id: leftContent

                    anchors.centerIn: parent

                    implicitWidth: childrenRect.width
                    implicitHeight: childrenRect.height
                }
            }

            opacity: enabled ? 1 : 0.48

            onClicked: root.clickLeft()
        }

        // ====================================================================
        // RIGHT BUTTON
        // ====================================================================

        Controls.AbstractButton {
            id: rightButton

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: 1

            enabled: root.enabledRight
            hoverEnabled: true
            focusPolicy: Qt.StrongFocus

            implicitWidth: Math.max(root.controlHeight, rightContent.implicitWidth + 2 * root.padding)

            implicitHeight: Math.max(root.controlHeight - 2 * root.inset, rightContent.implicitHeight + 2 * root.padding)

            background: Item {
                clip: true

                Surfaces.Surface {
                    width: parent.width * 2
                    height: parent.height

                    x: parent.width - width
                    y: 0

                    elevation: "flat"
                    cornerRadius: Dimensions.radiusPill

                    pressedColor: rightButton.down ? root.pressedColor : root.buttonColor

                    hoverColor: root.hoverColor
                    hovered: rightButton.hovered && !rightButton.down && rightButton.enabled

                    animateColors: root.animateColors
                }
            }

            contentItem: Item {
                Item {
                    id: rightContent

                    anchors.centerIn: parent

                    implicitWidth: childrenRect.width
                    implicitHeight: childrenRect.height
                }
            }

            opacity: enabled ? 1 : 0.48

            onClicked: root.clickRight()
        }
    }
}
